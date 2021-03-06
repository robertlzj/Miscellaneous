﻿#NoEnv
#SingleInstance,Force
#Include dataFromToClipboard.ahk
#Include HotKey_WhenEditInSciTE.ahk
#Include DelFileWithLink.ahk
;	DelFileWithLink_ExternalTrigger

Menu, Tray, Icon, fragmentShortcut-FS.ico
SetTitleMatchMode, 2
;	2: anywhere
goto fragmentShortcut_End

#IfWinActive inspection ahk_class AutoHotkeyGUI ahk_exe InternalAHK.exe
;	Object / Variable 
Esc::Send !{F4}
#IfWinActive [Debugging] ahk_class SciTEWindow ahk_exe SciTE.exe
~LButton::
	inspectVariableOn:=(A_PriorHotkey=A_ThisHotkey and A_TimeSincePriorHotkey<500)
	return
#If inspectVariableOn
~LButton up::
	if(A_TimeSincePriorHotkey>100 and A_PriorHotkey="~LButton"){
		Send +{F10}
		Sleep 200
		Send i	;Inspect variable...
	}
	return
#IfWinActive ahk_class SciTEWindow ahk_exe SciTE.exe
$F1::
	WinGet, OutputVar, ID ,AutoHotkey Help ahk_class HH Parent
	;	ahk_exe SciTE.exe ahk_exe hh.exe
	if OutputVar{
		;	WinActivate	;last found
		;	wont work
		dataFromToClipboard:=dataFromToClipboard()
		WinActivate	ahk_id %OutputVar%
		WinWaitActive	ahk_id %OutputVar%
		Send !2
		Sleep 200
		Send ^a
		dataFromToClipboard(dataFromToClipboard)
		Send {Enter}
	}else
		Send {F1}
	return

#IfWinActive ahk_class #32770, 否(&N)
;~ #IfWinActive ahk_class #32770 ahk_exe AutoHotkey, 否(&N)
;	not work
;~ #IfWinActive ahk_class #32770 ahk_exe AutoHotkey.exe, 否(&N)
;~ #IfWinActive ahk_class #32770 ahk_exe AutoHotkeyU32.exe, 否(&N)
Esc::!n

#IfWinActive, 删除 ahk_class #32770, 确实要	;{
;	"删除文件" / "删除多个项目"
;	"确实要把此文件放入回收站吗?" / "确实要永久性地删除此文件吗?" / "确实要将这 X 项移动到回收站吗?" / "确实要永久删除这 X 项吗?"
$Delete::Send {Enter}
#IfWinActive, 删除快捷方式 ahk_class #32770,你确定
;	"你确定要将此快捷方式移动到回收站吗?" / "你确定要永久删除此快捷方式吗?"
$Delete::Send {Enter}	;}

#IfWinActive	ahk_exe PotPlayerMini64.exe	;{
#IfWinActive 播放列表 ahk_exe PotPlayerMini64.exe
Del::
#IfWinActive ahk_class PotPlayer64 ahk_exe PotPlayerMini64.exe
	Del::
	PotPlayer_Del:
		Send +{Del}	;by default, del only apply to playlists
		WinWaitActive,删除 ahk_class #32770, 确实要, 1
		if not ErrorLevel
			;~ throw "WinWaitActive failed."
		;~ else
			gosub DelFileWithLink_ExternalTrigger
		return
	;	#IfWinActive 删除文件 ahk_class #32770 ahk_exe PotPlayerMini64.exe
	;		$Shift::
	;		$Delete::
	;			Send {Enter}
	;			return
	;		;	+Delete: in PotPlayer, delete file, prompt dialog whether to delete (to recycle bin)
	;Abstract.
	;	see "#IfWinActive, 删除 ahk_class #32770, 确实要“
	;Set by Logitech 游戏软件
	^i::	;click
		;~ if(A_ThisHotkey=A_PriorHotkey and A_TimeSincePriorHotkey<300)
			;~ Send {Del}
		;~ else
			Send {PGDN}
		return
	^b::	;long click
		Send {PGUP}
		return
	^u::	;press
		; MsgBox % A_ThisHotkey	;test
		goto PotPlayer_Del
#IfWinActive fragmentShortcut.ahk ahk_class #32770 ahk_exe AutoHotkey.exe, delete all entrance?
	$Del::Send !y
	~Esc::
		;	WinWaitNotActive,,,0.5
		;	WinActivate 删除 ahk_class #32770, 确实要
		;	WinWaitActive,A,,0.5
		WinWaitActive, 删除 ahk_class #32770, 确实要, 0.5
		if ErrorLevel
			throw "WinWaitActive failed."
		Send {Esc}
		return
;}

#If	;QQ screen capture	;{
~^+a::	;{
	OutputDebug, QQ screen capture Lunch
	WinWaitActive ahk_class TXGuiFoundation,,0.5
	if ErrorLevel
		return
	OutputDebug, QQ screen capture Ready to search
	Capturing:=true
	;	WinGetPos , X, Y, Width, Height
	;	ImageSearch, OutputVarX, OutputVarY, X, Y, Width, Height, *2 QQ screen capture QQ截图截屏 文字识别.bmp
	;	if(not ErrorLevel){	;1 not found, 2 error
	;		MouseMove, OutputVarX, OutputVarY
	;	}
	return	;}
#If Capturing
~LButton up::	;{
	WinGetPos , X, Y, Width, Height, A
	Sleep 100
	OutputDebug, QQ screen capture X: %X%`, Y: %Y%`, Width: %Width%`, Height: %Height%
	Capturing:=false
	ImageSearch, OutputVarX, OutputVarY, 0, 0, Width, Height, *5 QQ screen capture QQ截图截屏 文字识别.bmp
	;	background is transparent
	;	Coordinates are relative to the active window
	if(not ErrorLevel){	;1 not found, 2 error
		MouseMove, % OutputVarX+5, % OutputVarY+5
		;	Coordinates are relative to the active window
		OutputDebug, Found
	}else
		OutputDebug, Not found (%ErrorLevel%)
	return	;}
;}
#IfWinActive AutoHotkey Help ahk_class HH Parent ;ahk_exe SciTE.exe	;{
;	ahk_exe hh.exe
!1::!c
!2::Send !n^a
!3::Send !s^a
;}
;~ !`::
#If WinActive("ahk_class XLMAIN ahk_exe EXCEL.EXE")	;{
	;~ and (GetKeyState("Control") or GetKeyState("Alt"))
	and ClassUnderMouse()="EXCEL61"
~^LButton::
~!LButton::
~^!LButton::
	OutputDebug, % A_ThisHotkey
	Enable:=true
	return	;}
#If Enable	;{
~LButton up::	;{
	Enable:=false
	OutputDebug, % A_ThisHotkey
	if(A_PriorHotkey~="^~[!^]{1,2}LButton$" and A_TimeSincePriorHotkey>500){
		;~ and dataFromToClipboard()!=""
		if A_PriorHotkey~="\^"
			Send ^b
		if A_PriorHotkey~="!"
			Send ^i
	}
	return	;}
;}
ClassUnderMouse(){
	MouseGetPos , OutputVarX, OutputVarY, OutputVarWin, OutputVarControl
	return OutputVarControl
}
#IfWinActive ahk_exe msedge.exe	;{
~^d::	;favorite
	WinWaitActive 编辑收藏夹
	Send ^c{Esc}
	return
~!d::	;{address bar
	;	ControlGetFocus, outputVar, A
	;	ToolTip % "ControlGetFocus: " outputVar ", Caret: " A_CaretX
	;	get nothing (in Edge).
	;	if(outputVar="Intermediate D3D Window1")
	;		Send ^c{Esc}
	if(A_PriorHotkey=A_ThisHotkey and A_TimeSincePriorHotkey<800)
		Send ^c
	return
	;}
;}
#IfWinActive ▶ ahk_exe msedge.exe	;{
RControl::
#IfWinActive 网易云音乐 ahk_exe msedge.exe
RControl::	;{
	if (A_PriorHotkey=A_ThisHotkey and A_TimeSincePriorHotkey<500)
		Send ^{Right}
	Send p
	return	;}
;}
#IfWinActive ahk_exe msedge.exe	;游览器
+RControl::
!r::
	Send ^+u	;read aloud
	return
#IfWinActive ahk_exe SLDWORKS.exe
$d::
	MouseGetPos,OutputVarX, OutputVarY, OutputVarWin, OutputVarControl
	;	The retrieved coordinates are relative to the active window
	if(OutputVarControl~="^AfxMDIFrame"){
		Send d
		Sleep 200
		MouseMove, OutputVarX+20, OutputVarY+20
		;	Coordinates are relative to the active window
	}else if(A_PriorHotkey=A_ThisHotkey and A_TimeSincePriorHotkey<1000)
		Click
	return
#If

fragmentShortcut_End:
_:=_