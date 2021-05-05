#SingleInstance,Force
Menu, Tray, Icon, SG.ico
TrayTip, %A_ScriptName%, Launch,,16
#Include SelectOrReadSelection.ahk
Hotkey, If, Condition()
loop 10{
	index:=A_Index-1
	Hotkey,^%index%,MakeGroup
	Hotkey,%index%,GetGroup
}
#Include *i %A_ScriptName%.data
global Groups
if not Groups
	Groups:=[]
OnExit("SaveGroup")
return
#If WinActive("ahk_exe explorer.exe") and not A_CaretX
^`::
	if(A_PriorHotkey=A_ThisHotkey and A_TimeSincePriorHotkey<1000)
		ExitApp
	condition:=!condition
	if condition{
		Menu, Tray, Icon, SG(R).ico
		SoundPlay,*64	;info
		TrayTip, %A_ScriptName%, Start,,16
	}else{
		Menu, Tray, Icon, SG.ico
		TrayTip, %A_ScriptName%, Stop,,16
		SoundPlay,*48	;Exclamation
	}
	return
#If, Condition()
#If
Condition(){
	global condition
	if condition and WinActive("ahk_exe explorer.exe") and not A_CaretX {
		ControlGetFocus, OutputVar, A
		;~ ToolTip % OutputVar1
		if(OutputVar!="Windows.UI.Core.CoreWindow1")
			;ClassNN:	ModernSearchBox1
			return true
	}
	return false
}
MakeGroup:
	ret:=SelectOrReadSelection()
	index:=SubStr(A_ThisHotKey,2)
	Groups[index]:=StrSplit(ret,"`n")
	TrayTip, %A_ScriptName%, Update group %index%,,16
	SoundPlay,*-1
	return
GetGroup:
	index:=A_ThisHotKey
	if Groups[index]
		SelectOrReadSelection(Groups[index]*)
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