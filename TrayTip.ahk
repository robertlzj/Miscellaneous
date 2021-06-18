TrayTip(text,title:="",options:=""){
	;always hide previous one
	;AutoHotkey Help \ TrayTip
	if(options="" and (title+0=title))
		options:=title,title:=""
	if(toggle:=WinExist("ahk_exe PSTrayFactory.exe"))
		;toggle then restore icon state
		Suspend
	TrayTip
	Menu Tray, NoIcon
	Sleep 200  ; It may be necessary to adjust this sleep.
	Menu Tray, Icon
	;~ Sleep 200
	if toggle
		Suspend
	TrayTip % title?title:A_ScriptName,% text,,% options
	;	option: 0x10: Do not play the notification sound.
}
;	try to regex replace
;		TrayTip\s*,?\s*\([^,]*\),

if(A_ScriptFullPath=A_LineFile){	;test
	TrayTip("Content 1","Title")
	Sleep 2000
	TrayTip("Content 2",0x10)
	Sleep 2000
	TrayTip("Content 3")
}