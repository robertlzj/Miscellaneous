#SingleInstance,Force
#NoEnv
#Include HotKey_WhenEditInSciTE.ahk
Length:=0
Menu, Tray, Icon, EditFileName.ico
Menu, Tray, Tip, in explorer F2 to switch select section`nin editor F1 reload/F2 exit
#If WinActive("ahk_exe explorer.exe") and Rename()
F2::
	ControlGetText, OutputVar,% fileNameEditor,A
	FileName:=OutputVar
	FileAppend File name: %FileName%`n,*
	FileNameWithoutExt:=RegExReplace(FileName,"(\.[^.]*)?$","")
	TotalLength:=StrLen(FileNameWithoutExt)
	FileAppend File name without extension: %FileNameWithoutExt%`n,*
	NeedleRegEx :="P)¡¤?[^¡¤]+?.{" Length "," Length "}$"
	FoundPos:=RegExMatch(FileNameWithoutExt,NeedleRegEx,Length)
	FileAppend FoundPos: %FoundPos%`, Length: %Length%`n,*
	if FoundPos=1
		Send ^a
		;~ goto Abort
	else if not Length
		SendInput ^{Home}{Right %TotalLength%}
	else{
		SelectionLength:=Length-1
		SendInput  ^{Home}{Right %FoundPos%}+{Right %SelectionLength%}
	}
	return
#If WinActive("ahk_exe explorer.exe")
~F2::
Abort:
	FileNameWithoutExt:=Length:=TotalLength:=""
	return
Rename(){
	ControlGetFocus, OutputVar,A
	global fileNameEditor
	fileNameEditor:=OutputVar
	return ErrorLevel=0 and fileNameEditor~="^Edit\d"
	;	Edit1 may be path in address bar, then Edit2 is file name
	;		test in explorer on "C:\Users\RobertLin\Documents"
}
/* 
	#IfWinActive EditFileName.ahk  ahk_class SciTEWindow ahk_exe SciTE.exe
	F3::Reload
	F2::ExitApp
	#IfWinActive
 */