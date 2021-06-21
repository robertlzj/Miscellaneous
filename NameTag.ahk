;对MTP，批量选中后无法命名..
#NoEnv
#SingleInstance,Force
;todo: keep selection
#Include *i NameTag.data
#Include dataFromToClipboard.ahk
#Include TrayTip.ahk

	Menu, Tray, Tip, click F2 without selection to start/stop`,`nctrl 1~g to set`, 1~g to apply`nin editor F1 reload/F2 exit
	InputBoxHeight:=130
	separator:="·"
	if not dataArrary
		dataArrary:={}
	windowsEnable:={}
	;	[whnd]=true
	/* abandon
		if not previousExitTime
			previousExitTime:=A_TickCount
	 */
	TrayTip,Name Tag, Launch,,16
	Menu, Tray, Icon, Rn(B).ico
	;~ SoundPlay,*64	;info
	SoundPlay,*16	;failed
	shortcutKeyArray:=["1","2","3","4","5","q","w","e","r","a","s","d","f"]
	Hotkey,If,condition()
	for i,key in shortcutKeyArray{
		Hotkey,% key,handle
		Hotkey,% "^" key,setData
	}
	Hotkey,If
	OnExit("Save")
	Loop{	;prompt if window enables Name Tag
		WinWaitNotActive, A
		if WinActive("ahk_exe explorer.exe") or WinActive("ahk_class #32770"){
			whnd:=WinExist("A")	;get WHND
			windowEnable:=windowsEnable[whnd]
			if windowEnable{
				Menu, Tray, Icon, Rn(R).ico
				TrayTip("Continue","Name Tag",16)
				SoundPlay,*-1	;success
			}
		}
	}
	SystemErrorCodes={183:"Cannot create a file when that file already exists.Cannot create a file when that file already exists."
		,32:"The process cannot access the file because it is being used by another process."}
return

condition(){
	global windowsEnable
	whnd:=WinExist("A")	;get WHND
	windowEnable:=windowsEnable[whnd]
	return windowEnable and not A_CaretX and ((WinActive("ahk_exe explorer.exe") or WinActive("ahk_class #32770")))
}

#If WinActive("ahk_exe explorer.exe") or WinActive("ahk_class #32770")
~F2::
	Sleep 200
	ControlGetFocus, OutputVar,A
	;~ if dataFromToClipboard()
	if(OutputVar~="^Edit\d")	;edit file name
		Exit
	if(A_PriorHotkey=A_ThisHotkey and A_TimeSincePriorHotkey<800){
		TrayTip,Name Tag, Exit,,16
		SoundPlay,*48	;Exclamation
		Sleep 500
		ExitApp
	}
	whnd:=WinExist("A")	;get WHND
	windowsEnable[whnd]:=!windowsEnable[whnd]
	windowEnable:=windowsEnable[whnd]
	if windowEnable{
		Menu, Tray, Icon, Rn(R).ico
		;~ TrayTip,Name Tag, Start,,16
		TrayTip("Start","Name Tag",16)
		;~ SoundPlay,*64	;info
		SoundPlay,*-1	;success
	}else{
		Menu, Tray, Icon, Rn(B).ico
		;~ TrayTip,Name Tag, Stop,,16
		TrayTip("Stop","Name Tag",16)
		;~ SoundPlay,*48	;Exclamation
		SoundPlay,*16	;remove
	}
	return

#IfWinActive NameTag.ahk ahk_class SciTEWindow ahk_exe SciTE.exe
F3::
	Send ^s
	Reload
	return
F2::ExitApp

#If condition()
/* 
	^`::
		if A_TickCount-previousExitTime<2500{
			TrayTip,Name Tag, Exit,,16
			SoundPlay,*48	;Exclamation
			Sleep 500
			ExitApp
		}else
			Reload
 */
`::
	key:="``"
	gosub writeData
	if ErrorLevel	;cancel
		return
	goto handle
#IfWinActive
setData:
	key:=SubStr(A_ThisHotkey,2)
writeData:
	InputBox,outputVar,NameTag,Input name tag for shortkey "%key%",,,InputBoxHeight,,,,,% dataArrary[key ""]
	if ErrorLevel	;cancel
		return
	data:=outputVar
	dataArrary[key ""]:=data
	return
handle:	;edit file name
	key:=A_ThisHotkey
	data:=dataArrary[key ""]
	;~ if A_CaretX
		;~ data:=dataFromToClipboard()
	if not data{
		gosub, writeData
		if not data or ErrorLevel	;cancel
			return
	}
	dataArrary["``"]:=data
	if(previousData!=data){
		previousData:=data
		active:=key="``"?true:false
		;	first time/new start
	}
	filePath:=dataFromToClipboard()
	if(previousFilePath!=filePath){
		previousFilePath:=filePath
		active:=key="``"?true:false
		;	first time/new start
		WriteLog("for " data)
	}
	if not filePath
		return
	/* 
		fileAttribute:=FileExist(filePath)
		if(not fileAttribute or fileAttribute~="D")	;Directory
			return
	 */
	dataPattern:="[." separator " ]\Q" . data . "\E(?=[·.])"
	;	\b wont work correctly on string like chinese?
	;	\b is equivalent to [a-zA-Z0-9_]
	updateFileCount:=0
	activateFileCount:=0
	Loop, Parse, filePath, `n,`r
	{
		Loop, Files,% A_LoopField
		{
			;A_LoopFileName: A_LoopFileExt
			if not FileExist(A_LoopFileLongPath)
				continue
			if A_LoopFileName~=dataPattern{	;found
				newFileName:=RegExReplace(A_LoopFileName,dataPattern,"")
				if active	;then remove
					mode:="remove"
				else{	;skip
					mode:="activate"
					;~ newFileName:=""
					postfix:=A_LoopFileExt?("." . A_LoopFileExt):""
					newFileName:=(postfix?SubStr( newFileName,1,-StrLen(postfix)):newFileName) . separator . data . postfix
					activateFileCount++
				}
			}else{
				mode:="add"
				postfix:=A_LoopFileExt?("." . A_LoopFileExt):""
				newFileName:=(postfix?SubStr( A_LoopFileName,1,-StrLen(postfix)):A_LoopFileName) . separator . data . postfix
			}
			if newFileName{
				folderPath:=A_LoopFileDir . "\"
				;{update previousFilePath
					oldFileName:=SubStr(A_LoopFileLongPath,StrLen(folderPath)+1)
					;	;previousFilePath:=StrReplace(previousFilePath,oldFileName,newFileName,OutputVarCount)
					;	limitations: can't handle / distinguish between 'b' and 'a.b.c'
					previousFilePath:=RegExReplace(previousFilePath,"m)(?<=[/\\])\Q" . oldFileName . "\E$",newFileName,OutputVarCount)
					;	default newline character (`r`n)
					;	`n: Switches from the default newline character to a solitary linefeed (`n).
					;		also see: `r, `a
					;	Escaping can be avoided by using \Q...\E.
					if( not OutputVarCount=1)
						throw, "update previousFilePath failed!"
				;}
				FileMove,% A_LoopFileLongPath,% folderPath . newFileName
				updateFileCount++
				if(ErrorLevel!=0){
					;https://docs.microsoft.com/en-us/windows/win32/debug/system-error-codes
					MsgBox,,Name Tag Error, % "failed. " A_LastError SystemErrorCodes[A_LastError]
						. (A_LastError=32?"(file used)":"")
					;	32: The process cannot access the file because it is being used by another process.
					;	183: Cannot create a file when that file already exists.
					WriteLog(A_LoopFileLongPath " failed. " . A_LastError)
				}else
					WriteLog(A_LoopFileLongPath . "`t>`t" . newFileName)
			}
		}
	}
	text:="Renamed " (updateFileCount?("(" mode ")")?"") " " updateFileCount " file(s)"
	if activateFileCount
		text.="`n Activate " activateFileCount "file(s)"
	;~ TrayTip,Name Tag, % text,,16
	TrayTip(text,"Name Tag",16)
	active:=true
	SoundPlay % (activateFileCount or mode="add" or mode="activate")?"*-1":"*16"
	return
WriteLog(log){
	if log
		FileAppend,% A_Now "`t:" log "`n",NameTag.log.txt,UTF-8
}
Save(){
	global dataArrary
	save:=""
	for key,data in dataArrary
		save.=(save?",":"") . """" (key="``"?"````":key) """:""" data """`n"
	save:=Trim(save,"`n")
	save:="dataArrary:={" save "}"
	;save.="`npreviousExitTime:=" . A_TickCount
	;	abandon
	fileObject:=FileOpen("NameTag.data","w")
	fileObject.Write(save)
	fileObject.Close()
}