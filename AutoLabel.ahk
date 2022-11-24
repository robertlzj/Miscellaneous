#SingleInstance, Force
#Include HotKey_WhenEditInSciTE.ahk
;~ #Include dataFromToClipboard.ahk
SendMode, Input
/*Usage:
	select nothing, click Alt+S to insert last label, press Alt + click S one more time to generate new free label
	select label, click Alt+S to copy for last label, press Alt + click S one more time to change to new free label
*/
/*
	Problem: in Edge, #s/#q which from system is availble, which from autohotkey is disable.
*/
Menu, Tray, Icon, AutoLabel.ico
Menu, Tray, Tip, #s to copy selected label`, or insert last label if exist`, or generate new one`, win+s to generate next free index new label

LabelExists:={}
return

GenerateNewLabel(){
	global lastLabel,LabelExists
	Loop{
		lastLabel:=A_YYYY . A_MM . A_DD . "_" . A_Index
	}until not LabelExists[lastLabel]	;new one
	;~ ToolTip GenerateNewLabel: %lastLabel%
	
	;~ SetTimer, ResetLastLabel, -600000
	;	disable auto reset. 20221124
}
InsertAndSelectLabel(){
	global length,lastLabel,LabelExists,insertLabelAndKeepModifier
	Clipboard:=lastLabel
	;	ClipWait, 0.2
	;	need wait?
	length:=StrLen(lastLabel)
	Send ^v
	if insertLabelAndKeepModifier:=GetKeyState("LWin","P")
		Send +{Left %length%}
	LabelExists[lastLabel]:=true
	Sleep 100
	;	necessary. wait before restore clipboard
}

#If	;{
~$LWin up::
	if insertLabelAndKeepModifier
		Send +{Right %length%}
		;	when select C:A, move caret (C) with one right arrow key,
		;	will get different result in different application,
		;	some move to C-1, some move to A
		;	use shift + arrow key to move with one position step.
	Sleep 500
	insertLabelAndKeepModifier:=false
	return
#If	;}

#If not insertLabelAndKeepModifier	;{
;	remove "and A_CaretX", for there is no A_CaretX in some case (edit in web browser)
#s::	;{
	originalClipboard:=ClipboardAll
	Clipboard:=""
	if HID_StandardStatusBar:=WinActive("ahk_exe zbstudio.exe"){
		StatusBarGetText, statusBarText, 4, ahk_id %HID_StandardStatusBar%
		if (not statusBarText~="Sel:")
			goto AfterCopy
	}
	Send ^c
AfterCopy:
	ClipWait, 0.2
	;~ ToolTip % "A_CaretX: " . A_CaretX . ", Clipboard: " . Clipboard . ", ErrorLevel: " . ErrorLevel
	originalMatchMode:=A_TitleMatchMode
	SetTitleMatchMode, 2
	;	20220302_2. used for WinActive
	if !ErrorLevel and Clipboard~="^\d{8}_\d+$"{
		;	20220301
		lastLabel:=Clipboard
		insertLabelAndKeepModifier:=GetKeyState("LWin","P")
	}else if ErrorLevel	;ClipWait expires - there is no selection
		or WinActive("- ½Úµã±à¼­Æ÷ ahk_exe msedge.exe"){	;special handle for nspirit editer - no matter if selected or not
		;	20220302_2
		;~ ToolTip % "Clipboard: " . Clipboard . ", ErrorLevel: " . ErrorLevel
			;~ . "`nlastLabel: " . lastLabel
		if not lastLabel{	;generate one
			GenerateNewLabel()
		}
		InsertAndSelectLabel()
	}
	SetTitleMatchMode % originalMatchMode
	Clipboard:=originalClipboard
	return	;}
#If	;}

#If insertLabelAndKeepModifier	;{
#s::	;{
	originalClipboard:=ClipboardAll
	GenerateNewLabel()
	InsertAndSelectLabel()
	Clipboard:=originalClipboard
	return	;}
#If	;}

ResetLastLabel:	;{
	lastLabel:=""
	return	;}