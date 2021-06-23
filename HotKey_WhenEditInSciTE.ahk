;will turn script permanently running
;usage:
;	#Include HotKey_WhenEditInSciTE.ahk
;	[HotKey_WhenEditInSciTE(["$F2"])]
;	;	default F2 to reload then exit app
;~ #SingleInstance, Force
TimeSinceLunch:=A_TickCount
Hotkey, IfWinActive, %A_ScriptName% ahk_exe SciTE.exe
Hotkey, $F2, SciTE_Edit_ReloadThenExist	;default
Hotkey, IfWinActive
goto SciTE_Edit_End
HotKey_WhenEditInSciTE(hotkey){
	Hotkey, IfWinActive, %A_ScriptName% ahk_exe SciTE.exe
	Hotkey, $F2, , Off
	Hotkey, % hotkey, SciTE_Edit_ReloadThenExist, On
	Hotkey, IfWinActive
}
SciTE_Edit_ReloadThenExist:
	if(A_TickCount-TimeSinceLunch<1000)
		ExitApp
	Send ^s
	Reload
SciTE_Edit_End:
_:=_