#SingleInstance,Force
#NoEnv
#Include dataFromToClipboard.ahk
Menu, Tray, Icon, PowerWord.ico
;~ CoordMode, Mouse, Screen
;~ CoordMode, Pixel, Screen
SetDefaultMouseSpeed,0
#If WinActive("ahk_class QTool ahk_exe PowerWord.exe") and not GetKeyState("Alt","P")
LAlt::
RAlt::
	WinGetPos , _WinPos_X, _WinPos_Y, WinPos_Width, WinPos_Height, A
	FileAppend, % "Win X:" _WinPos_X ", Y: " _WinPos_Y ", WinPos_Width: " WinPos_Width ", WinPos_Height: " WinPos_Height "`n", *
	;	didn't use _WinPos_X, _WinPos_Y
	if WinPos_Height=96	;collapsed
		return
	if not SearchIcon()
		return
	if(A_ThisHotkey="RAlt")
	{
		FileAppend, search right side, *
		if not SearchIcon(ImageSearch_OutputVarX_lastFound+5){	;search right side
			FileAppend, search bellow, *
			SearchIcon(,ImageSearch_OutputVarY_lastFound+5)	;search bellow
		}
	}
	MouseGetPos , MouseX_original, MouseY_original
	;	The retrieved coordinates are relative to the active window
	FileAppend % "Mouse Pos: " MouseX_original " " MouseY_original, *
	;~ Sleep 200
	Random, r, 1, 10
	X_target:=ImageSearch_OutputVarX_lastFound+r
	Y_target:=ImageSearch_OutputVarY_lastFound+r
	if A_CaretX{
		;	A_CaretX/A_CaretY is sometimes zero.
		;	The coordinates are relative to the active window
		X_caret:=A_CaretX+5
		Y_caret:=A_CaretY+5
		FileAppend, Caret Pos: %X_caret%   %Y_caret%`n,*
	}
	Click ,%X_target%, %Y_target%
	if A_CaretX
		Click ,%X_caret%, %Y_caret%
	else
		Send % "{Tab " (A_ThisHotkey="RAlt"?4:5) "}"
	Send {End}
	/* useless
		ControlFocus, floatingLineEdit, A
		if ErrorLevel
			MsgBox error
		ControlFocus, QWidget17, A
		if ErrorLevel
			MsgBox error
 */
	/* 
			return
		#If WinActive("ahk_class QTool ahk_exe PowerWord.exe") 
		LAlt up::
		RAlt up::
	 */
	MouseMove MouseX_original, MouseY_original
	return
#IfWinActive PowerWordReadOut.ahk ahk_exe SciTE.exe
F1::Reload
F2::ExitApp
SearchIcon(X_offset:=0, Y_offset:=0){
	global
	local OutputVarX
	local OutputVarY
	try
		;~ ImageSearch, OutputVarX, OutputVarY, _WinPos_X, Y, X+WinPos_Width, Y+WinPos_Height, *2 金山词霸 发音 图标.bmp
		ImageSearch, OutputVarX, OutputVarY, X_offset, Y_offset, WinPos_Width, WinPos_Height, *2 金山词霸 发音 图标.bmp
		;	Coordinates are relative to the active window
	catch e
		MsgBox % "Message: " e.Message ", what: " e.what ", Extra: " e.Extra
		;	nothing important
	if ErrorLevel{	;1 not found, 2 error
		FileAppend, % ErrorLevel=1?"not found`n":"error", *
		return
	}else{
		FileAppend, % "found at: " OutputVarX "," OutputVarY "`n", *
		ImageSearch_OutputVarX_lastFound:=OutputVarX
		ImageSearch_OutputVarY_lastFound:=OutputVarY
	}
	return true
}
#If
$!+f::
	;~ Send ^c
	contentToSearch:=dataFromToClipboard()
	Send !+f
	WinWaitActive ahk_class QTool ahk_exe PowerWord.exe,,0.5
	if ErrorLevel
		return
	Send ^a
	dataFromToClipboard(contentToSearch)
	Send {Enter}
	return

#IfWinActive ahk_exe msedge.exe	;游览器
!r::Send ^+u	;read aloud
#If

