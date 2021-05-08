#NoEnv
#SingleInstance,Force
#If WinActive("ahk_exe SciTE.exe")
F1::ExitApp
/* 
	MsgBox % previousFilePath:=RegExReplace("a\b\ab`na\b\aab`na\b\abb`na\b\ab\a`na\b\ab","m`n)(?<=[/\\])\Q" . "ab" . "\E$","c") ", " ErrorLevel 
 */
#If
F1::
	FileSelectFile, OutputVar , M3, , ,
	;	FileSelectFile, OutputVar , Options, RootDir\Filename, Title, Filter
	;	M3: 3=1+2
	;		1: File Must Exist
	;		2: Path Must Exist
	if not OutputVar
		MsgBox Cancel
	else if ErrorLevel
		MsgBox Error
	else
		MsgBox % OutputVar
	if 0{
		if not OutputVar{
			MsgBox, The user pressed cancel.
			return
		}
		Loop, parse, OutputVar, `n
		{
			if (A_Index = 1)
				MsgBox, The selected files are all contained in %A_LoopField%.
			else
			{
				MsgBox, 4, , The next file is %A_LoopField%.  Continue?
				IfMsgBox, No, break
			}
		}
	}
	return
F2::
	MsgBox % dataFromClipboard()
	return
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
;----
dataFromClipboard(){
	;cant get path on external device like phone
	originalClipboard:=ClipboardAll
	Clipboard=
	ClipWait,0.5
	Send ^c
	ClipWait,0.5
	clipboard := clipboard	; Convert any copied files, HTML, or other formatted text to plain text.
	text:=Clipboard
	Clipboard:=originalClipboard
	return text
}