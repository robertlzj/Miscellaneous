#NoEnv
#SingleInstance,Force
Menu, Tray, Icon, fragmentShortcut-FS.ico
#IfWinActive fragmentShortcut.ahk - SciTE4AutoHotkey ahk_class SciTEWindow ahk_exe SciTE.exe
F1::Reload
F2::ExitApp
#IfWinActive AutoHotkey Help ahk_class HH Parent ahk_exe SciTE.exe
!1::!c
!2::Send !n^a
!3::Send !s^a
;~ !`::