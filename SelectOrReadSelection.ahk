#SingleInstance,Force
#Include  ExplorerOpenAndSelect.ahk
#Include  Get paths of selected items in an explorer window.ahk
If (A_ScriptFullPath=A_LineFile){
	Hotkey,F1,F1_SelectOrReadSelection
	Hotkey, IfWinActive, ahk_exe SciTE.exe
	Hotkey,F1,Exit_SelectOrReadSelection
	Hotkey, IfWinActive
	return
	F1_SelectOrReadSelection:
		ret := SelectOrReadSelection()
		if(ret){
			FileAppend, % ret, *, UTF-8
			If (A_ScriptFullPath=A_LineFile)
				MsgBox, % ret
		}
		return
	Exit_SelectOrReadSelection:
		ExitApp
}
SelectOrReadSelection(params*){
	opens:=(A_ScriptFullPath=A_LineFile)?A_Args:params
	length:=opens.Length()
	if(length=1)
		OpenAndSelect(opens[1],"")
	else if(length>=2)
		OpenAndSelect(opens*)
	else if(length!=0)
		throw "args error."
	else{
		path := Explorer_GetPath()
		sel := Explorer_GetSelected()
		ret := path . (sel?"`n" . sel:"") 
		return ret
	}
}