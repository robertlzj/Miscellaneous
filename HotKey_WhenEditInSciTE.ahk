;will turn script permanently running
;usage:
;	#Include HotKey_WhenEditInSciTE.ahk
Hotkey, IfWinActive, %A_ScriptName% ahk_exe SciTE.exe
Hotkey, $F2, SciTE_Edit_Reload
Hotkey, $F3, SciTE_Edit_Exit
Hotkey, IfWinActive
goto SciTE_Edit_End
SciTE_Edit_Reload:
	Send ^s
	Reload
SciTE_Edit_Exit:
	ExitApp
SciTE_Edit_End:
_:=_