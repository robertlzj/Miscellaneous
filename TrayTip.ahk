TrayTip(title,text,options){
	;always hide previous one
	;AutoHotkey Help \ TrayTip
	Menu Tray, NoIcon
	Sleep 200  ; It may be necessary to adjust this sleep.
	Menu Tray, Icon
	TrayTip % title,% text,,% options
}
;	try to regex replace
;		TrayTip\s*,?\s*\([^,]*\),