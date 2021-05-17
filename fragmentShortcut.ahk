#NoEnv
#SingleInstance,Force
Menu, Tray, Icon, fragmentShortcut-FS.ico
SetTitleMatchMode, 2
;	2: anywhere
#IfWinActive fragmentShortcut.ahk  ahk_class SciTEWindow ahk_exe SciTE.exe
F1::Reload
F2::ExitApp
#IfWinActive AutoHotkey Help ahk_class HH Parent ahk_exe SciTE.exe
!1::!c
!2::Send !n^a
!3::Send !s^a
;~ !`::
#IfWinActive ▶ ahk_exe msedge.exe
RControl::
#IfWinActive 网易云音乐 ahk_exe msedge.exe
RControl::
	if (A_PriorHotkey=A_ThisHotkey and A_TimeSincePriorHotkey<500)
		Send ^{Right}
	Send p
	return
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