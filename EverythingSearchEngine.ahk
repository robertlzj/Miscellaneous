#NoEnv
#SingleInstance, Force
;See
;	https://www.autohotkey.com/boards/viewtopic.php?t=67868
;	https://www.autohotkey.com/boards/viewtopic.php?t=25063#p118613
;	https://www.autohotkey.com/boards/viewtopic.php?t=7015
;	https://www.voidtools.com/support/everything/sdk/
;	https://www.voidtools.com/forum/viewtopic.php?t=8477	RegEx Search - voidtools forum
;		see bellow

EverythingDll := "Everything" . (A_PtrSize == 8 ? "64" : "32") . ".dll"
EverythingMod := DllCall("LoadLibrary", "Str", A_ScriptDir . "\" . EverythingDll, "Ptr")
if not EverythingMod
	throw EverythingDll " not found."
OnExit("EverythingSearchEngine_OnExit")
If (A_ScriptFullPath=A_LineFile){ ;test
	search:=EverythingDll
	search=regex:"(?<=^Every)th" regex:ing\d+ Files\
	;	C:\ProgramFiles\EverythingToolbar-0.5.2\Everything64.dll
	Loop{
		inputbox, search, Search in everything:, Cancel to clear input`, then exit.`nRegEx enabled.,, 300, 150,,,,,% search
		if(ErrorLevel)
			if(search="")
				ExitApp
			else
				search:=""
		else{
			results:=Search(search)
			for path,file in results{
				MsgBox % 0x4, Found,% A_Index "/" results.Count() ". Continue?`n"
					;	0x4: Yes/No
					. path
					. "`n"
					. (file?file:"<directory>")
				IfMsgBox, No
					break
			}
		}
	}
	#IfWinActive EverythingSearchEngine.ahk  ahk_class SciTEWindow ahk_exe SciTE.exe
	$F1::
		Send ^s
		Reload
		return
	$F2::ExitApp
}

Search(search){
	global EverythingDll
	DllCall(EverythingDll . "\Everything_SetSearch", "Str", search)
	DllCall(EverythingDll . "\Everything_Query", "Int", True)
	;~ if not DllCall(EverythingDll . "\Everything_Query", "Int", True)
		;~ throw "Failed."
	;~ DllCall(EverythingDll . "\Everything_SetRegex", "Int", enableRegex)
	resultCount:=DllCall(EverythingDll . "\Everything_GetNumResults", "UInt")
	if not resultCount
		return
	results:={}
	result.SetCapacity(resultCount+1)
	static GetResultPath:=EverythingDll . "\Everything_GetResultPath"
	Loop % resultCount
	{
		index:=A_Index - 1
		folder:=DllCall(EverythingDll . "\Everything_GetResultPath", "UInt", index, "Str")
		;	result different from GetResultPath
		file:=DllCall(EverythingDll . "\Everything_GetResultFileName", "UInt", index, "Str")
		attribute:=DllCall(EverythingDll . "\Everything_GetResultAttributes", "UInt", index)
		;	always -1
		;~ . " [" . DllCall(EverythingDll . "\Everything_GetResultExtension", "UInt", A_Index - 1, "Str") . "]"
		;~ . " [" . DllCall(EverythingDll . "\Everything_GetResultDateModified", "UInt", A_Index - 1, "Str") . "]"
		;	not work?
		path:=folder "\" file
		;	results[path]:=InStr(FileExist(path),"D")?false:file	;is file
		;	slow
		results[path]:=InStr(attribute,"D")?false:file	;is file
	}
	return results
}
EverythingSearchEngine_OnExit(){
	global EverythingDll,EverythingMod
	DllCall(EverythingDll . "\Everything_Reset")
	DllCall("FreeLibrary", "Ptr", EverythingMod)	
}