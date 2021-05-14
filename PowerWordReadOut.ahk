#SingleInstance,Force
#NoEnv
#Include dataFromClipboard.ahk
SetDefaultMouseSpeed,0
#If WinActive("ahk_class QTool ahk_exe PowerWord.exe") and not GetKeyState("Alt","P")
LAlt::
RAlt::
	WinGetPos , X, Y, Width, Height, A
	FileAppend, % "Win X:" X ", Y: " Y ", Width: " Width ", Height: " Height "`n", *
	if Height=96	;collapsed
		return
	if not SearchIcon()
		return
	if(A_ThisHotkey="RAlt")
	{
		if not SearchIcon(OutputVarX+5)	;search right side
			if not SearchIcon(,OutputVarX+5)	;search bellow
				SearchIcon(X,Y)	;use last
	}
	MouseGetPos , OutputVarX_mouse, OutputVarY_mouse
	;~ Sleep 200
	Random, r, 1, 10
	X_target:=OutputVarX_original+r
	Y_target:=OutputVarY_original+r
	;~ MouseMove X_target, Y_target
	Click ,%X_target%, %Y_target%
	Sleep 200
	Click ,%A_CaretX%, %A_CaretY%
	Sleep 200
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
	MouseMove OutputVarX_mouse, OutputVarY_mouse
	return
#IfWinActive ahk_exe SciTE.exe
F1::ExitApp
SearchIcon(X:=0, Y:=0){
	global
	try
		;~ ImageSearch, OutputVarX, OutputVarY, X, Y, X+Width, Y+Height, *2 金山词霸 发音 图标.bmp
		ImageSearch, OutputVarX, OutputVarY, X, Y, Width, Height, *2 金山词霸 发音 图标.bmp
	catch e
		MsgBox % "Message: " e.Message ", what: " e.what ", Extra: " e.Extra
		;	nothing important
	if ErrorLevel{	;1 not found, 2 error
		FileAppend, % ErrorLevel=1?"not found`n":"error", *
		return
	}else{
		FileAppend, % "found at: " OutputVarX "," OutputVarY "`n", *
		OutputVarX_original:=OutputVarX
		OutputVarY_original:=OutputVarY
	}
	return true
}
#If
$!+f::
	;~ Send ^c
	dataFromClipboard(true)
	Send !+f
	WinWaitActive ahk_class QTool ahk_exe PowerWord.exe,,0.5
	if ErrorLevel
		return
	Send ^a
	Send ^v{Enter}
	return

#IfWinActive ahk_exe msedge.exe	;游览器
!r::Send ^+u	;read aloud
#If

