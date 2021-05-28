#SingleInstance,Force
#If WinActive("ahk_exe explorer.exe") and Rename()
F2::
	if not FileNameWithoutExt
	{
		ControlGetText, OutputVar,Edit1,A
		FileName:=OutputVar
		FileAppend File name: %FileName%,*
		FileNameWithoutExt:=RegExReplace(FileName,"(\.[^.]*)?$","")
		FileAppend File name without extension: %FileNameWithoutExt%,*
		Length:=0
	}
	NeedleRegEx :="P)¡¤?[^¡¤]+?.{" Length "," Length "}$"
	FoundPos:=RegExMatch(FileNameWithoutExt,NeedleRegEx,Length)
	FileAppend FoundPos: %FoundPos%, Length: %Length%,*
	Length:=FoundPos-1
	Send {Home}{Right %FoundPos%}+{Right %Length%}
	if not Length or FoundPos=1
		goto Abort
	return
Abort:
	FileNameWithoutExt:=Length:=0
	return
Rename(){
	ControlGetFocus, OutputVar,A
	return ErrorLevel=0 and OutputVar="Edit1"
}
#IfWinActive EditFileName.ahk  ahk_class SciTEWindow ahk_exe SciTE.exe
F1::Reload
F2::ExitApp
#IfWinActive