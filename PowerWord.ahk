#SingleInstance,Force
#NoEnv
#Include dataFromToClipboard.ahk
#Include HotKey_WhenEditInSciTE.ahk
Menu, Tray, Icon, PowerWord.ico
;全面使用屏幕(Screen)坐标	;{
	CoordMode, Mouse, Screen
	;	金山词霸不一定具有焦点。
	;	默认为："Relative"。
	CoordMode, Pixel, Screen
	CoordMode, Caret, Screen
;}
SetDefaultMouseSpeed,0
Window_Attribute:="ahk_class QTool ahk_exe PowerWord.exe"
;	局限："划译"（划词翻译）与"悬浮窗"都是此窗口特征，但窗口内容不同。
;		差异：
;			- "划译"，"Active Window Info - Visible Text - SelectSearchEditWindow"
;			- "悬浮窗"：.. "MiniAdvertisementWindow"

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
#If WinExist(Window_Attribute) and not GetKeyState("Alt","P")	;{
~LAlt::
RAlt::
	WinGetPos , _WinPos_X, _WinPos_Y, WinPos_Width, WinPos_Height, % Window_Attribute
	;	WinPos_Width, WinPos_Height used in SearchIcon
	FileAppend, % "Win X:" _WinPos_X ", Y: " _WinPos_Y ", WinPos_Width: " WinPos_Width ", WinPos_Height: " WinPos_Height "`n", *
	;	didn't use _WinPos_X, _WinPos_Y
	targetImageFile:="金山词霸 迷你窗口 发音 图标.bmp"
	if WinPos_Height=96	;collapsed
		return
	;search first one from left/top
	Is_Win_Active:=WinActive(Window_Attribute)
	if(Is_Win_Active && false){	;全面使用屏幕(Screen)坐标
		CoordMode, Pixel, Relative
		if not SearchIcon(targetImageFile)
			return
	}else{
		;~ CoordMode, Pixel, Screen
		if not SearchIcon(targetImageFile,_WinPos_X, _WinPos_Y)	;search first one from left/top
			return
	}
	if(A_ThisHotkey="RAlt")
	{
		FileAppend, search right side`n, *
		if not SearchIcon(targetImageFile,ImageSearch_OutputVarX_lastFound+5){	;search again start from right side of first one
			FileAppend, search bellow`n, *
			SearchIcon(targetImageFile,0,ImageSearch_OutputVarY_lastFound+5)	;search again start from lower side of first one
		}
	}
	MouseGetPos , MouseX_original, MouseY_original
	;	The retrieved coordinates are relative to the active window
	FileAppend % "Mouse Pos: " MouseX_original " " MouseY_original "`n", *
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
	;全面使用屏幕(Screen)坐标
	;~ if(not Is_Win_Active)
		;~ CoordMode, Mouse, Screen
	Click ,%X_target%, %Y_target%
	;~ if(not Is_Win_Active)	;restore
		;~ CoordMode, Mouse, Relative
	if A_CaretX
		Click ,%X_caret%, %Y_caret%
	;~ else
		;~ Send % "{Tab " (A_ThisHotkey="RAlt"?4:5) "}"
	;	会移动到错误的焦点，导致窗口折叠
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
		#If WinActive(Window_Attribute) 
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
		ImageSearch, OutputVarX, OutputVarY, X_offset, Y_offset, X_offset+WinPos_Width, Y_offset+WinPos_Height, % "*2 " . ImageFile
		;~ ImageSearch, OutputVarX, OutputVarY, 0, 0, 9999, 9999, % "*2 " . ImageFile
		;	Coordinates are relative to the active window
	catch e{
		FileAppend, % "ImageSearch catch e: `n`tMessage: " e.Message ", what: " e.what ", Extra: " e.Extra
			. "`n`tX_offset: " X_offset ", Y_offset: " Y_offset ", WinPos_Width: " WinPos_Width ", WinPos_Height: " WinPos_Height 
			.  "`n", *
		;	nothing important
		return
	}
	if ErrorLevel{	;1 not found, 2 error
		FileAppend, % (ErrorLevel=1?"not found":"error")
			. "`n`tX_offset: " X_offset ", Y_offset: " Y_offset ", WinPos_Width: " WinPos_Width ", WinPos_Height: " WinPos_Height
			. "`n", *
		return
	}else{
		FileAppend, % "found at: " OutputVarX "," OutputVarY "`n", *
		ImageSearch_OutputVarX_lastFound:=OutputVarX
		ImageSearch_OutputVarY_lastFound:=OutputVarY
	}
	return true
}
#If not WinExist(Window_Attribute)	;{
$+!f::	;"软件设置-热键设置-显示/隐藏悬浮窗"
	;~ Send ^c
	contentToSearch:=dataFromToClipboard()
	Send !+f
	WinWaitActive % Window_Attribute,,0.5
	if ErrorLevel
		return
	Send ^a
	dataFromToClipboard(contentToSearch)
	Send {Enter}
	return
#If	;}
#If WinExist(Window_Attribute) and not WinActive(Window_Attribute)	;{
/*	功能：更新搜索内容。
*/
~LButton::
	if not (A_ThisHotkey==A_PriorHotkey && A_TimeSincePriorHotkey<200)
		return
$+!f::	;"软件设置-热键设置-显示/隐藏悬浮窗"
	contentToSearch:=dataFromToClipboard()
	WinActivate, % Window_Attribute
	Send ^a
	dataFromToClipboard(contentToSearch)
	Send {Enter}
	return
#If	;}

#If WinActive(Window_Attribute)	;{
~Esc::	;{
	/*	期望：内容为空时关闭窗口。
		阻碍："Active Window Info"无法获取正确的内容（进而猜测`ControlGetText`同样如此）。
		绕行：如下，双击Esc时关闭窗口。
	*/
	
	if(A_PriorHotkey==A_ThisHotkey && A_TimeSincePriorHotkey<600)
		Send +!f	;"软件设置-热键设置-显示/隐藏悬浮窗"
	return	;}
#If	;}

/*
	22/2/11	rename from "PowerWordReadOut"
*/