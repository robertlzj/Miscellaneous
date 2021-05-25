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
		if(ret)
			FileAppend, % ret, *
		return
	Exit_SelectOrReadSelection:
		ExitApp
}
SelectOrReadSelection(params*){
	opens:=(A_ScriptFullPath=A_LineFile)?A_Args:params
	length:=opens.Length()
	if(length=1)
		OpenAndSelect(opens[1],"")
		;	如果不传入空，则会打开上级，选中文件夹
	else if(length>=1)
		OpenAndSelect(opens*)
	else if(length!=0)
		throw "args error."
	else{
		path := Explorer_GetPath()
		if(path="ERROR")
			return
		sel := Explorer_GetSelected()
		if(sel="ERROR")
			return
		ret := path . (sel?"`n" . sel:"") 
		return ret
	}
}