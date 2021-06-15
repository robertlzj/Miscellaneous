#NoEnv
#SingleInstance, Force
;See
;	https://www.autohotkey.com/boards/viewtopic.php?t=67868
;	https://www.autohotkey.com/boards/viewtopic.php?t=25063#p118613
;	https://www.autohotkey.com/boards/viewtopic.php?t=7015
;	https://www.voidtools.com/support/everything/sdk/

EverythingDll := "Everything" . (A_PtrSize == 8 ? "64" : "32") . ".dll"
EverythingMod := DllCall("LoadLibrary", "Str", A_ScriptDir . "\" . EverythingDll, "Ptr")
if not EverythingMod
	throw EverythingDll " not found."
OnExit("EverythingSearchEngine_OnExit")
If (A_ScriptFullPath=A_LineFile){ ;test
	search:=EverythingDll
	Loop{
		inputbox, search, Search in everything:, Cancel to exit.`nRegEx enabled.,, 300, 150,,,,,% search
		if(ErrorLevel or search="")
			ExitApp
		Search(search,true)
	}
}

Search(search,regex){
	global EverythingDll
	DllCall(EverythingDll . "\Everything_SetSearch", "Str", search)
	DllCall(EverythingDll . "\Everything_Query", "Int", True)
	DllCall(EverythingDll . "\Everything_SetRegex", "Int", regex)
	Loop % DllCall(EverythingDll . "\Everything_GetNumResults", "UInt")
	{
		MsgBox % 0x4, Found,% "Continue?`n"
			;	0x4: Yes/No
			. DllCall(EverythingDll . "\Everything_GetResultFileName", "UInt", A_Index - 1, "Str")
			. " [" . DllCall(EverythingDll . "\Everything_GetResultPath", "UInt", A_Index - 1, "Str") . "]"
			;~ . " [" . DllCall(EverythingDll . "\Everything_GetResultExtension", "UInt", A_Index - 1, "Str") . "]"
			;~ . " [" . DllCall(EverythingDll . "\Everything_GetResultDateModified", "UInt", A_Index - 1, "Str") . "]"
			;	not work?
		IfMsgBox, No
			Exit
	}
}
EverythingSearchEngine_OnExit(){
	global EverythingDll,EverythingMod
	DllCall(EverythingDll . "\Everything_Reset")
	DllCall("FreeLibrary", "Ptr", EverythingMod)	
}

#IfWinActive EverythingSearchEngine.ahk  ahk_class SciTEWindow ahk_exe SciTE.exe
$F1::
	Send ^s
	Reload
	return
$F2::ExitApp