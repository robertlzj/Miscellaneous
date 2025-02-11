#SingleInstance Force
/* Use mouse to select, release mouse button with LControl pressed will copy and paste selection to QQNotepad.
*/
#Include dataFromToClipboard.ahk
#Include HotKey_WhenEditInSciTE.ahk
Menu, Tray, Icon, SC.ico
while(true){
	currentActiveWindow:=WinExist("A") 
	WinWaitNotActive, ahk_id %currentActiveWindow%
	;	WinWaitNotActive, A
	;	not work between two Edge (but works between two notepad)
	lastActiveWindow:=currentActiveWindow
	OutputDebug, lastActiveWindow is: %lastActiveWindow%.
}
return

#IfWinActive QQNotepad
F1::
	Enable:=not Enable
	ToolTip,% "释放后粘贴 " . (Enable?"开":"关")
	SetTimer,ToolTip_Tip, -1000
	return
ToolTip_Tip:
	ToolTip
	return
#If

#If Enable
~*LButton::
	OutputDebug, ~LButton
	p:=A_TickCount
	return
#If GetKeyState("LControl")==1 and not IsHangOut() and Enable
~*LButton up::
	OutputDebug, ~*LButton up with LControl down
	if(A_TickCount-p<200){	;click
		OutputDebug, skip click.
		LButtonUpWithLControlDown:=false
		return
	}
	LButtonUpWithLControlDown:=true
	return
#If GetKeyState("LButton")==1 and not IsHangOut()
$^c::
	;	originalClipboard:=ClipboardAll
	;	Clipboard=
	;	Send, ^c
	;	ClipWait, 1
	;	if(ErrorLevel==1)
	;		return
	;	ContentToPaste:=true
	ContentToPaste:=dataFromToClipboard()
	OutputDebug, % "Copy & Paste" (ContentToPaste?" (ContentToPaste exist)":"")
	return
#If LButtonUpWithLControlDown
*~LControl up::
	LButtonUpWithLControlDown:=false
	ContentToPaste:=dataFromToClipboard()
	OutputDebug,% "LControl up "  (ContentToPaste?"(ContentToPaste exist)":"")
	if not ContentToPaste
		return
	if(lastActiveWindow and lastActiveWindow!=currentActiveWindow and WinExist("ahk_id " lastActiveWindow)){
		WinActivate, ahk_id %lastActiveWindow%
		_:=currentActiveWindow
		currentActiveWindow:=lastActiveWindow
		lastActiveWindow:=_
		OutputDebug, lastActiveWindow is: %lastActiveWindow%.
	}else{
		OutputDebug, Activate QQNotepad
		_:=WinExist("A")
		Send #``
		WinWaitActive ahk_exe QQNotepad_V2.12.exe,,0.5
		if ErrorLevel{	;timeout
			OutputDebug, Activate OONotepad failed.
			return
		}
		currentActiveWindow:=WinExist("A")
		if currentActiveWindow!=_
			lastActiveWindow:=_
	}
	if false{
		Input i,L1 T2,{esc} ;,{enter}{,}{space}
		if(ErrorLevel~="EndKey")
			return
		if(i){
			lastInput:=i
			OutputDebug, Update input "%i%"
		}
		ContentToPaste.=i?i:lastInput
	}
	method:=2
	if(method==1)
		SendInput % ContentToPaste
	else{
		;	Send ^v
		dataFromToClipboard(ContentToPaste)
		Sleep 200
	}
	;	Clipboard:=originalClipboard
	ContentToPaste:=""
	return
IsHangOut(winTitle:="A"){
	MouseGetPos,,,OutputVarWin
	return OutputVarWin!=WinActive(winTitle)
}
#IfWinActive SelectThenCopyToQQNotepad.ahk ahk_exe SciTE.exe
F3::Reload
F2::ExitApp