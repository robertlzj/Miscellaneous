#SingleInstance Force
/* Use mouse to select, release mouse button with LControl pressed will copy and paste selection to QQNotepad.
*/
Menu, Tray, Icon, SC.ico
while(true){
	currentActiveWindow:=WinExist("A") 
	WinWaitNotActive,A
	lastActiveWindow:=currentActiveWindow
	OutputDebug, lastActiveWindow is: %lastActiveWindow%.
}
return
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
	ClipWait, 1
	if(ErrorLevel==1)
		return
	EnablePaste:=true
	return
#If EnablePaste
*~LControl up::
	OutputDebug, LControl up (EnablePaste==true)
	EnablePaste:=false
	if(lastActiveWindow and lastActiveWindow!=currentActiveWindow and WinExist("ahk_id " lastActiveWindow)){
		WinActivate, ahk_id %lastActiveWindow%
		_:=currentActiveWindow
		currentActiveWindow:=lastActiveWindow
		lastActiveWindow:=_
		OutputDebug, lastActiveWindow is: %lastActiveWindow%.
	}else{
		lastActiveWindow:=WinExist("A")
		Send #``
		currentActiveWindow:=WinExist("A")
	}
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
	method:=2
	if(method==1)
		SendInput % Clipboard
	else{
		Send ^v
		Sleep 200
	}
	Clipboard:=originalClipboard
	return
IsHangOut(winTitle:="A"){
	MouseGetPos,,,OutputVarWin
	return OutputVarWin!=WinActive(winTitle)
}