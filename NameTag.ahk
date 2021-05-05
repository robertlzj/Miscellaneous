#NoEnv
#SingleInstance,Force
;~ a:={1:"A","1":"B"}
;~ return
#Include *i NameTag.data
if not dataArrary
	dataArrary:={}
shortcutKeyArray:=["1","2","3","4","5","q","w","e","r","a","s","d","f"]
Hotkey,IfWinActive,ahk_exe explorer.exe
for i,key in shortcutKeyArray{
	Hotkey,% key,handle
	Hotkey,% "^" key,setData
}
Hotkey,IfWinActive
OnExit("Save")
return
`::ExitApp
setData:
	key:=SubStr(A_ThisHotkey,2)
writeData:
	InputBox,outputVar,NameTag,Input name tag,,,150,,,,,% dataArrary[key]
	if ErrorLevel	;cancel
		return
	data:=outputVar
	dataArrary[key]:=data
	return
handle:
	key:=A_ThisHotkey
	data:=dataArrary[key ""]
	;~ if A_CaretX
		;~ data:=dataFromClipboard()
	if not data{
		gosub, writeData
		if not data or ErrorLevel	;cancel
			return
	}
	filePath:=dataFromClipboard()
	if not filePath
		return
	fileAttribute:=FileExist(filePath)
	if(not fileAttribute or fileAttribute~="D")	;Directory
		return
	Loop, Files,% filePath
	{
		;A_LoopFileName: 含 A_LoopFileExt
		log:="for " data
		if A_LoopFileName~=data{
			newFileName:=RegExReplace(A_LoopFileName,"[.· ]" . data,"")
		}else{
			newFileName:=SubStr( A_LoopFileName,1,-StrLen(A_LoopFileExt)-1) . "." . data . "." . A_LoopFileExt
		}
		FileMove,% A_LoopFileLongPath,% A_LoopFileDir . "\" . newFileName
		WriteLog(A_LoopFileLongPath . "`t>`t" . newFileName)
	}
	return
	
dataFromClipboard(){
	originalClipboard:=ClipboardAll
	Clipboard=
	ClipWait,0.1
	Send ^c
	ClipWait,0.1
	clipboard := clipboard	; Convert any copied files, HTML, or other formatted text to plain text.
	text:=Clipboard
	Clipboard:=originalClipboard
	return text
}
WriteLog(log){
	if log
		FileAppend,% A_Now "`t:" log "`n",NameTag.log.txt,UTF-8
}
Save(){
	global dataArrary
	save:=""
	for key,data in dataArrary
		save.=(save?",":"") . """" key """:""" data """`n"
	save:=Trim(save,"`n")
	save:="dataArrary:={" save "}"
	fileObject:=FileOpen("NameTag.data","w")
	fileObject.Write(save)
	fileObject.Close()
}