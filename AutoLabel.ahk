#SingleInstance, Force
#Include HotKey_WhenEditInSciTE.ahk
;~ #Include dataFromToClipboard.ahk
SendMode, Input
/*Usage:
	select nothing, click Alt+S to insert last label, press Alt + click S one more time to generate new free label
	select label, click Alt+S to copy for last label, press Alt + click S one more time to change to new free label
*/

LabelExists:={}
return

GenerateNewLabel(){
	global lastLabel,LabelExists
	Loop{
		lastLabel:=A_YYYY . A_MM . A_DD . "_" . A_Index
	}until not LabelExists[lastLabel]	;new one
	;~ ToolTip GenerateNewLabel: %lastLabel%
}
InsertAndSelectLabel(){
	global length,lastLabel,LabelExists,insertLabelAndKeepModifier
	Clipboard:=lastLabel
	;	ClipWait, 0.2
	;	need wait?
	length:=StrLen(lastLabel)
	Send ^v
	;~ Sleep 200
	if insertLabelAndKeepModifier:=GetKeyState("Alt","P")
		Send +{Left %length%}
	LabelExists[lastLabel]:=true
}

#If	;{
~$Alt up::
	if insertLabelAndKeepModifier
		Send {Right %length%}
	insertLabelAndKeepModifier:=false
	return
#If	;}

#If A_CaretX and not insertLabelAndKeepModifier	;{
!s::	;{
	originalClipboard:=ClipboardAll
	Clipboard:=""
	Send ^c
	ClipWait, 0.2
	if ErrorLevel{	;expires
		if not lastLabel{	;generate one
			GenerateNewLabel()
		}
		InsertAndSelectLabel()
	}else if Clipboard~="^\d{8}_\d+$"{
		;	20220301
		lastLabel:=Clipboard
		insertLabelAndKeepModifier:=GetKeyState("Alt","P")
	}
	Clipboard:=originalClipboard
	return	;}
#If	;}

#If insertLabelAndKeepModifier	;{
!s::	;{
	originalClipboard:=ClipboardAll
	GenerateNewLabel()
	InsertAndSelectLabel()
	Clipboard:=originalClipboard
	return	;}
#If	;}