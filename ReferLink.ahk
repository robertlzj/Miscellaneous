#SingleInstance,Force
#NoEnv
#Include TrayTip.ahk
if(ReferLink_StandAlone:=A_ScriptFullPath=A_LineFile){
	#Include HotKey_WhenEditInSciTE.ahk
	Menu, Tray, Icon, ReferLink.ico
	Hotkey, If, previousFileSelected && not A_CaretX && WinActive("ahk_exe explorer.exe")
	Hotkey, ~Esc, ReferLink~Esc
	Hotkey, If, not A_CaretX && WinActive("ahk_exe explorer.exe")
	Hotkey, !c, ReferLink!c
	Hotkey, ~^c, ReferLink~^c
	Hotkey, !x, ReferLink!x
	Hotkey, !v, ReferLink!v
	Hotkey, !z, ReferLink!z
	Hotkey, If, not A_CaretX && WinActive("ReferLink.ahk ahk_class #32770")
	Hotkey, !z, ReferLink!z2
	Hotkey, IfWinActive, ReferLink.ahk ahk_class #32770 ahk_exe AutoHotkey.exe
	Hotkey, !x, ReferLink!x2
	Hotkey, If
}
IsDebug:=IsDebug?IsDebug:ReferLink_StandAlone
if IsDebug
	SetBatchLines -1
if(not A_IsAdmin and not IsDebug){
	;	see A_IsAdmin / Operating System and User Info / Built-in Variables / Variables and Expressions
	;	see Run as Administrator / Run[Wait]
	Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	;	could not debug..
	ExitApp
}
#Include dataFromToClipboard.ahk
#Include CheckIfIsSymlinkFileOrDirectoryOrNot.ahk
;	GetDirectTarget
#Include Get paths of selected items in an explorer window.ahk
#Include ExplorerOpenAndSelect.ahk
;	OpenAndSelect
#Include CommandLine.ahk
;	RunWaitOne, HandleSpaceInPath
#Include EverythingSearch.ahk
;	Search
GetFileSelected:=""
	;~ . "dataFromToClipboard"
	. "ShellGetSelected"
c:=""""
e:=""
goto ReferLink_End

#If previousFileSelected && not A_CaretX && WinActive("ahk_exe explorer.exe")
	ReferLink~Esc:	;{
		SoundPlay,*16
		gosub ResetSelectedRecord
		return	;}
#If not A_CaretX && WinActive("ahk_exe explorer.exe")
ReferLink!c:	;switch between current select or final source of select as source for operation follow-up
ReferLink~^c:	;same as above but silent
ReferLink!x:	;{abstract file
	isSilent:=A_ThisHotkey~="~" or A_ThisHotkey="!x"	;~^c
	gosub GetSourceFilePath
	SplitPath, sourceFilePath , sourceFileName, sourceDirPath, sourceFileExtension, sourceFileNameWithoutExt
	;	The final backslash is not included even if the file is located in a drive's root directory.
	if(A_ThisHotkey="!x"){
		while(sourceMode!="Final")
			gosub GetSourceFilePath
		if(finalSource=fileSelected){
			Default:=sourceFileNameWithoutExt
			while true
			{
				InputBox, OutputVar,,Source File Name: %sourceFileName% `n%prompt%Set Abstract Identifier (without extension),,,160,,,,,% Default
				referFileNameWithoutExt:=OutputVar
				if ErrorLevel ;cancel
					goto Abort
				referFolderPath:=sourceDirPath "\_ReferStorage_"
				referFilePath:=referFolderPath "\" referFileNameWithoutExt "." sourceFileExtension
				if not FileExist(referFilePath){
					prompt:=e
					break
				}
				prompt:="Identifier Name Exist.`n "
				Default:=referFileNameWithoutExt
			}
			Default:=e
			;{Move
				if not FileExist(referFolderPath)
					FileCreateDir, % referFolderPath
				moved:=false
				FileMove,% sourceFilePath,% referFilePath
				;	The destination directory must already exist
				if ErrorLevel{	;number of files that could not be moved due to an error
					MsgBox File not move. Last Error: %A_LastError%.`nFrom: %sourceFilePath%`nTo: %referFilePath%.
					;	0x3: The system cannot find the path specified.
					;	112: There is not enough space on the disk.
					goto Abort
				}
				moved:=true
			;}
			referFilePathWithQuotation:=HandleSpaceInPath(referFilePath)
			;~ MsgBox % (referFileNameWithoutExt=sourceFileName) "`n" referFileNameWithoutExt "`," sourceFileName	;test
			if(referFileNameWithoutExt!=sourceFileNameWithoutExt){
				;	;and not referFilePath~=("^""?\Q" sourceFileName "\E[·.]")
				;	;	\b wont work correctly on string like chinese?
				;	;	\b is equivalent to [a-zA-Z0-9_]
				MsgBox ,% 0x3|0x20,,Yes to change original file name to contain identifier?`nOr no to keep original and create an extra map file.
				IfMsgBox, Yes
					originalFilePath:=sourceDirPath "\" referFileNameWithoutExt "·" sourceFileName
				IfMsgBox, No
				{
					originalFilePath:=sourceFilePath
					extraMapFilePath:=sourceDirPath "\" sourceFileNameWithoutExt "·" (referFileNameWithoutExt=sourceFileNameWithoutExt?"":referFileNameWithoutExt) "." sourceFileExtension
					if FileExist(extraMapFilePath){
						MsgBox %extraMapFilePath% exist.
						goto Abort
					}
					HandleSpaceInPath(extraMapFilePath)
					RunWaitOne("ln --symbolic " . referFilePathWithQuotation . " " . extraMapFilePath)
					extraMapFilePath:=e
				}
				IfMsgBox, Cancel
					goto Abort
			}else
				originalFilePath:=sourceFilePath
			RunWaitOne("ln --symbolic " . referFilePathWithQuotation . " " . HandleSpaceInPath(originalFilePath))
			;~ referFilePath:=Trim(referFilePath,c)
			originalFilePath:=e
			Sleep 200
			Send  {F5}
			;~ MsgBox % sourceDirPath "\" referFileNameWithoutExt "." sourceFileExtension ;test
			OpenAndSelect(sourceDirPath,referFileNameWithoutExt "." sourceFileExtension)
		}else
			referFilePath:=finalSource
		targetFilePath:=e
	}else{	;!c
		referFilePath:=sourceFilePath
	}
	SplitPath, referFilePath , _referFileName, _referDirPath, referFileExtension, referFileNameWithoutExt
	FileAppend, % "referFilePath: " referFilePath . "`n",*
	referFilePathWithQuotation:=HandleSpaceInPath(referFilePath)
	return	;}
ResetSelectedRecord:	;{
	previousFileSelected:=finalSource:=""
	sourceMode:="Direct"
	return	;}
Abort:	;{
	if moved{	;cancel / move back
		;~ MsgBox,% referFilePath "`n" sourceFilePath	;test
		FileMove,% referFilePath,% sourceFilePath
		;~ MsgBox % ErrorLevel "`n" A_LastError	;test
		;	A_LastError:
		;		123: The filename, directory name, or volume label syntax is incorrect.
		moved:=false
	}
	referFilePath:=e
	Exit	;}
ReferLink!v:	;{
	if not referFilePath
		Exit
	targetFolder:=Explorer_GetPath()
	;~ MsgBox % targetFolder	;test
	if not targetFolder
		Exit
	targetIndex:=e
	if(FileExist(targetFilePath:=targetFolder . referFileNameWithoutExt . (referFileExtension?("." referFileExtension):e)))
		while true{
			targetFileName:=referFileNameWithoutExt . ("·" . targetIndex) . (referFileExtension?("." referFileExtension):e)
			targetFilePath:=targetFolder . targetFileName
			;~ MsgBox % targetFilePath	;test
			if not FileExist(targetFilePath)
				break
			targetIndex++
		}
	FileAppend, % "targetFilePath: " targetFilePath . "`n", *
	command:="ln --symbolic " . referFilePathWithQuotation . " " . HandleSpaceInPath(targetFilePath)
	;	shift upstream
	;~ MsgBox % command
	;	MsgBox % IsAdmin_TestByWScriptCommand() "," A_IsAdmin
	;	;	test result conflict - false, true (0,1).
	resutl:=RunWaitOne(command)
	;	symbolic links can only be successfully created from an administrative command prompt. ln.exe will fail on symbolic links from a normal command prompt!
	;	/ --symbolic Symbolic Links / ln - command line hardlinks
	;~ MsgBox ,,,% resutl
	FileAppend, % "Command Return Value: " resutl, *	;for test/debug
	;	failed, get:
	;	ln 2.933
	;	success on Robert Work
	
	;	while not FileExist(targetFilePath)
	;		Sleep 200
	;not needed.
	
	;	Send {Alt up}
	;	;	if there is no interval, then source file will still be selected.
	;	;		not related with Alt, even alt is held down and "v" is released.
	;need update, use {F5} or Sleep for a while
	;	Sleep 1000
	Send  {F5}
	;~ OpenAndSelect(targetFolder,"")
	OpenAndSelect(targetFolder,targetFileName)
	;~ Send  {F2}
	;~ Send  {F2}
	;~ Send  {F2}
	;~ MsgBox %targetFolder%`n%targetFileName%
	return	;}
ReferLink!z:	;{	search entrance
	isSilent:=false
	,previousOutput:=output:=""
	gosub GetSourceFilePath
SearchEntrance:
	if(not output){
		SplitPath, sourceFilePath , sourceFileName, sourceDirPath, sourceFileExtension, sourceFileNameWithoutExt
		if(results:=GetAllEntraces(sourceFilePath)){
			target:=results.TargetPath
			,length:=results.Length()
			,ouputs:=""
			Loop % length
				ouputs.=results[A_Index] "`n"
			RTrim(ouputs,"`n")
			output=%sourceMode% Target path: %target%.`nIts %length% entrance:`n%ouputs%
		}
	}
	MsgBox % output?output:"No entrance found."
	return	;}
#If not A_CaretX && WinActive("ReferLink.ahk ahk_class #32770")	;{
ReferLink!z2:
	_:=previousOutput,previousOutput:=output,output:=_
	Send {Enter}	;close MsgBox
	gosub Toggle_Mode	
	SetTimer, SearchEntrance, -1
	return
#If	;}
GetSourceFilePath: ;{
	fileSelected:=%GetFileSelected%()
	if not FileExist(fileSelected)	;or multiple files then
		return
	if(previousFileSelected!=fileSelected)
		gosub ResetSelectedRecord
Toggle_Mode:
	if(not previousFileSelected){
		if not isSilent
			SoundPlay,*-1
		else
			SoundPlay,Click.mp3
		sourceFilePath:=previousFileSelected:=fileSelected
	}else if(previousFileSelected=fileSelected){
		sourceMode:=sourceMode="Direct"?"Final":"Direct"
		if(not finalSource and sourceMode="Final"){
			finalSource:=fileSelected
			while(_:=GetDirectTarget(finalSource))
				finalSource:=_
		}
		SoundPlay,% sourceMode="Final"?"ClickDouble.mp3":"Click.mp3",1
	}else throw "Should not execute here."
	sourceFilePath:=sourceMode="Direct"?fileSelected:finalSource
	if(not isSilent)	;~^c,	Silent
		TrayTip(sourceFilePath,sourceMode " Source:",0x10)
		;	0x10: Do not play the notification sound.
	return
;}

ShellGetSelected(){
	folder:=Explorer_GetPath()
	file:=Explorer_GetSelected()
	return folder . file
}
;{GetAllEntraces
	GetAllEntraces_Core(id,results){
		static Label_TargetPath:=0x1,Label_Recorded:=0x2
		aliases:=[]
		FileAppend, Handle id: %id%, *
		results["_" id]:=Label_Recorded
		if((ResultCount:=(found:=Search(id)).Count())>10000){
 			MsgBox Abort.`nToo many results (%ResultCount%) to retrieve attributes.
			return
		}
		if(found:=Search(id " attrib:L")){
			for path_relate in found
				if((_1:=results[targetPath:=GetDirectTarget(path_relate)])&Label_TargetPath
					and not (_2:=results[path_relate])&Label_Recorded){
					results[targetPath]:=(results[targetPath]?results[targetPath]:0)|Label_TargetPath
					,results[path_relate]:=(results[path_relate]?results[path_relate]:0)|Label_Recorded|Label_TargetPath
					,results.Push(path_relate)
					FileAppend, Found path: %path_relate%, *
					if RegExMatch(path_relate,"O).+\\(.+?)·" id "(?=·|.|$)",match){
						id_alias:=match[1]
						if(results["_" id_alias])	;Label_Recorded
							throw "Duplicate id & its alias."
						FileAppend, Found id_alias: %id_alias%, *
						aliases.Push(id_alias)
					}
				}
		}
		if(length:=aliases.Length()>0){
			FileAppend, Handle ailias id, *
			Loop % length
				GetAllEntraces_Core(id_alias:=aliases[A_Index],results)
		}
	}
	GetAllEntraces(path){
		static Label_TargetPath:=0x1
		if(not FileExist(path))
			throw """%path%"" not a path."
		FileAppend, Handle path: %path%, *
		if not RegExMatch(path,"O).+\\(.+?)(?=·|\.|$)",match)
			throw "should always find a name(id)."	;expect name like "·"
		id:=match[1]
		FileAppend, Its id: %id%, *
		results:={TargetPath:path,(path):Label_TargetPath}
		GetAllEntraces_Core(id,results)
		return results.Length()>0?results:false
	}
;}
#IfWinActive ReferLink.ahk ahk_class #32770 ahk_exe AutoHotkey.exe	;Set Abstract Identifier
	ReferLink!x2:
		Send {Enter}	;use current file name
		return
#IfWinActive

ReferLink_End:
_:=_