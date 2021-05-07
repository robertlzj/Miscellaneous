MsgBox % previousFilePath:=RegExReplace("a\b\ab`na\b\aab`na\b\abb`na\b\ab`na\b\ab\a","m)(?=[/\\])\Q" . "ab" . "\E$","c") ", " ErrorLevel 
ExitApp
q:: ;desktop get paths of selected files (tested on Windows 7)
;MsgBox, % JEE_ExpGetSelDesktop()
MsgBox, % Clipboard := JEE_ExpGetSelDesktop("`r`n")
return

JEE_ExpGetSelDesktop(vSep="`n")
{
	oWindows := ComObjCreate("Shell.Application").Windows
	VarSetCapacity(hWnd, 4, 0)
	;SWC_DESKTOP := 0x8 ;VT_BYREF := 0x4000 ;VT_I4 := 0x3 ;SWFO_NEEDDISPATCH := 0x1
	oWin := oWindows.FindWindowSW(0, "", 8, ComObject(0x4003, &hWnd), 1)
	vCount := oWin.Document.SelectedItems.Count
	vOutput := ""
	VarSetCapacity(vOutput, (260+StrLen(vSep))*vCount*2)
	for oItem in oWin.Document.SelectedItems
		if !(SubStr(oItem.path, 1, 3) = "::{")
			vOutput .= oItem.path vSep
	oWindows := oWin := oItem := ""
	return SubStr(vOutput, 1, -StrLen(vSep))
}