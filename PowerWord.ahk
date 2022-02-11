#SingleInstance,Force
#NoEnv
#Include dataFromToClipboard.ahk
#Include HotKey_WhenEditInSciTE.ahk
Menu, Tray, Icon, PowerWord.ico
;~ CoordMode, Mouse, Screen
;~ CoordMode, Pixel, Screen
SetDefaultMouseSpeed,0
#If WinActive("ahk_class QWidget ahk_exe PowerWord.exe") and not GetKeyState("Alt","P")	;{
LAlt::
RAlt::
	WinGetPos , _WinPos_X, _WinPos_Y, WinPos_Width, WinPos_Height, A
	;	WinPos_Width, WinPos_Height used in SearchIcon
	targetImageFile:="金山词霸 主窗口 发音 图标.bmp"
	if not SearchIcon(targetImageFile)	;search first one from left/top
		return
	else{
		if(A_ThisHotkey="RAlt"){
			if not SearchIcon(targetImageFile,ImageSearch_OutputVarX_lastFound+5){	;search again start from right side of first one
				SearchIcon(targetImageFile,0,ImageSearch_OutputVarY_lastFound+5)	;search again start from lower side of first one
			}
		}
		Random, r, 1, 10
		X_target:=ImageSearch_OutputVarX_lastFound+r
		Y_target:=ImageSearch_OutputVarY_lastFound+r
	}
	;{store
		MouseGetPos , MouseX_original, MouseY_original
		;	The retrieved coordinates are relative to the active window
		if A_CaretX{
			;	A_CaretX/A_CaretY is sometimes zero.
			;	The coordinates are relative to the active window
			X_caret:=A_CaretX+5
			Y_caret:=A_CaretY+5
			FileAppend, Caret Pos: %X_caret%   %Y_caret%`n,*
		}
	;}store
	Click ,%X_target%, %Y_target%
	;{restore
		if A_CaretX
			Click ,%X_caret%, %Y_caret%
		MouseMove MouseX_original, MouseY_original
	;}restore
	return
#If	;}
#If WinActive("ahk_class QTool ahk_exe PowerWord.exe") and not GetKeyState("Alt","P")	;{
LAlt::
RAlt::
	WinGetPos , _WinPos_X, _WinPos_Y, WinPos_Width, WinPos_Height, A
	;	WinPos_Width, WinPos_Height used in SearchIcon
	FileAppend, % "Win X:" _WinPos_X ", Y: " _WinPos_Y ", WinPos_Width: " WinPos_Width ", WinPos_Height: " WinPos_Height "`n", *
	;	didn't use _WinPos_X, _WinPos_Y
	targetImageFile:="金山词霸 迷你窗口 发音 图标.bmp"
	if WinPos_Height=96	;collapsed
		return
	if not SearchIcon(targetImageFile)	;search first one from left/top
		return
	if(A_ThisHotkey="RAlt")
	{
		FileAppend, search right side, *
		if not SearchIcon(targetImageFile,ImageSearch_OutputVarX_lastFound+5){	;search again start from right side of first one
			FileAppend, search bellow, *
			SearchIcon(targetImageFile,0,ImageSearch_OutputVarY_lastFound+5)	;search again start from lower side of first one
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
#If	;}
	/* 
		#IfWinActive PowerWordReadOut.ahk ahk_exe SciTE.exe
		F3::Reload
		F2::ExitApp
	*/
SearchIcon(ImageFile, X_offset:=0, Y_offset:=0){
	global
	;	input global: WinPos_Width, WinPos_Height
	;	output global: ImageSearch_OutputVarX_lastFound, ImageSearch_OutputVarY_lastFound
	;	;ImageSearch_OutputVarX_lastFound:=0, ImageSearch_OutputVarY_lastFound:=0
	;	should not clear last result
	local OutputVarX
	local OutputVarY
	try
		;~ ImageSearch, OutputVarX, OutputVarY, _WinPos_X, Y, X+WinPos_Width, Y+WinPos_Height, *2 金山词霸 发音 图标.bmp
		ImageSearch, OutputVarX, OutputVarY, X_offset, Y_offset, WinPos_Width, WinPos_Height, % "*2 " . ImageFile
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
#If

/*
	22/2/11	rename from "PowerWordReadOut"
*/