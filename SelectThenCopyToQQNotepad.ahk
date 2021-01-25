#SingleInstance Force
/* Use mouse to select, release mouse button with LControl pressed will copy and paste selection to QQNotepad.
*/
~*LButton::
	OutputDebug, ~*LButton
	p:=A_TickCount
	return
#If GetKeyState("LControl")==1 and not IsHangOut()
~*LButton up::
	OutputDebug, ~*LButton up with LControl down
	if(A_TickCount-p<200){
		OutputDebug, skip.
		return
	}
#If GetKeyState("LButton")==1 and not IsHangOut()
$^c::
	OutputDebug, Copy & Paste
	originalClipboard:=ClipboardAll
	Clipboard=
	Send, ^c
	ClipWait, 0.5
	if(ErrorLevel==1)
		return
	EnablePaste:=true
	return
#If EnablePaste
*~LControl up::
	EnablePaste:=false
	if WinActive("ahk_exe QQNotepad_V2.12.exe"){
		Send !{Tab}
		WinWaitNotActive
	}else{
		Send #``
		if false{
			Input i,L1 T2,{esc} ;,{enter}{,}{space}
			if(ErrorLevel~="EndKey")
				return
			if(i){
				lastInput:=i
				OutputDebug, Update input "%i%"
			}
			Clipboard.=i?i:lastInput
		}
	}
	method:=2
	if(method==1)
		SendInput % Clipboard
	else{
		Send ^v
		Sleep 200
	}
	;Clipboard:=originalClipboard
	return
IsHangOut(winTitle:="A"){
	MouseGetPos,,,OutputVarWin
	return OutputVarWin!=WinActive(winTitle)
}