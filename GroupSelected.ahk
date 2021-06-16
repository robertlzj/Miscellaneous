#SingleInstance,Force
#NoEnv
Menu, Tray, Icon, SG.ico
TrayTip, %A_ScriptName%, Launch,,16
#Include SelectOrReadSelection.ahk
Hotkey, If, Condition()
loop 10{
	index:=A_Index-1
	Hotkey,^%index%,MakeGroup
	Hotkey,+^%index%,AddGroup
	Hotkey,%index%,GetGroup
}
#Include *i %A_ScriptName%.data
global Groups
if not Groups
	Groups:=[]
OnExit("SaveGroup")
return
#If not A_CaretX and (WinActive("ahk_exe explorer.exe") or WinActive("ahk_class #32770"))
^`::
	if(A_PriorHotkey=A_ThisHotkey and A_TimeSincePriorHotkey<1000)
		if condition	;triple
			ExitApp
		else	;double
			condition:=true
	else
		condition:=false
	;~ condition:=!condition
	if condition{
		Menu, Tray, Icon, SG(R).ico
		;~ SoundPlay,*64	;info
		SoundPlay,*-1	;success
		TrayTip, %A_ScriptName%, Start,,16
	}else{
		Menu, Tray, Icon, SG.ico
		TrayTip, %A_ScriptName%, Stop,,16
		;~ SoundPlay,*48	;Exclamation
		SoundPlay,*16	;failed
	}
	return
#If, Condition()
#IfWinActive GroupSelected.ahk  ahk_class SciTEWindow ahk_exe SciTE.exe
F3::Reload
F2::ExitApp
#IfWinActive
#If
Condition(){
	global condition
	if condition and not A_CaretX and (WinActive("ahk_exe explorer.exe") or WinActive("ahk_class #32770")){
		ControlGetFocus, OutputVar, A
		;~ ToolTip % OutputVar1
		if(OutputVar!="Windows.UI.Core.CoreWindow1")
			;ClassNN:	ModernSearchBox1
			return true
	}
	return false
}
MakeGroup:
	FileAppend, MakeGroup `n, *
	ret:=SelectOrReadSelection()
	if not ret{
		TrayTip, %A_ScriptName%, Failed,,16
		SoundPlay,*16
		FileAppend, MakeGroup: Fialed`n, *
		return
	}
	index:=SubStr(A_ThisHotKey,2)
	group:=StrSplit(ret,"`n")
	path:=group[1]
	file1:=group[2]
	if not path{
	
	}
	Groups[index]:=group
	count:=group.Length()
	FileAppend, MakeGroup: Done. Index=%index%`, Count=%count%`n`, Path=%path%`, File1=%file1%, *
MakeGroup_Done:
	TrayTip, %A_ScriptName%, Set group %index% with %count% file(s),,16
	SoundPlay,*-1
	return
AddGroup:
	ret:=SelectOrReadSelection()
	index:=SubStr(A_ThisHotKey,3)
	arrayToAdd:=StrSplit(ret,"`n")
	group:=Groups[index]
	if(not group){
		Groups[index]:=arrayToAdd
		goto MakeGroup_Done
	}else{
		count:=0
		for i,item_toAdd in arrayToAdd
		{
			for i,item_exist in group
				if(item_exist=item_toAdd)
					continue,2
			group.Push(item_toAdd)
			count++
		}
	}
	TrayTip, %A_ScriptName%, Update group %index% with %count% file(s),,16
	SoundPlay,*-1
	return
GetGroup:
	index:=A_ThisHotKey
	if Groups[index]
		SelectOrReadSelection(Groups[index]*)
	;~ MsgBox % Groups[1] ", " Groups[1][1] ", " Groups[1][2] ", " Groups[1][3]
	return
/* 
	DataFileName(){
		return SubStr(A_ScriptName,0,-4) . "data.ahk"
	} 
*/
SaveGroup(){
	TrayTip, %A_ScriptName%, Exit And Save,,16
	SoundPlay,*48	;Exclamation
	file:=FileOpen(A_ScriptName . ".data","rw")
	data:=""
	for index,subGroup in Groups{ 
		subData:=""
		for _,item in subGroup
			subData.=(subData?"`n,":"") . """" .  item . """"
		if subData
			data.=(data?"`n,":"") . "[" . subData . "]"
	}
	data:="Groups:=[" . data . "]"
	file.Write(data)
	file.Close()
	Sleep 4000
}