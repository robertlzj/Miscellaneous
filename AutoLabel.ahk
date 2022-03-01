#SingleInstance, Force
#Include HotKey_WhenEditInSciTE.ahk
;~ #Include dataFromToClipboard.ahk
SendMode, Input

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
	global length,lastLabel,LabelExists
	Clipboard:=lastLabel
	;	ClipWait, 0.2
	;	need wait?
	length:=StrLen(lastLabel)
	Send ^v
	;~ Sleep 200
	if GetKeyState("Alt","P")
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
		if(not insertLabelAndKeepModifier:=GetKeyState("Alt","P"))
			Send {Right %length%}
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
	ToolTip 2
	GenerateNewLabel()
	InsertAndSelectLabel()
	Clipboard:=originalClipboard
	return	;}
#If	;}