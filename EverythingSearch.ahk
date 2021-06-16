#NoEnv
#SingleInstance, Force
#Include HotKey_WhenEditInSciTE.ahk
;See
;	https://www.autohotkey.com/boards/viewtopic.php?t=67868
;	https://www.autohotkey.com/boards/viewtopic.php?t=25063#p118613
;	https://www.autohotkey.com/boards/viewtopic.php?t=7015
;	https://www.voidtools.com/support/everything/sdk/
;	https://www.voidtools.com/forum/viewtopic.php?t=8477	RegEx Search - voidtools forum
;		see bellow
;	The Everything 1.4 SDK does not support multiple instances
;		https://www.voidtools.com/forum/viewtopic.php?f=12&t=9857

IsFileMethod:="RequestAttribute"
;~ IsFileMethod:="FileExist"
;	affect query mode, both will slow query.
;~ IsFileMethod:="No"

;{EverythingSearch_Initial
	global IsFileMethod
	EverythingDll := "Everything" . (A_PtrSize == 8 ? "64" : "32") . ".dll"
	Folder:=SubStr(A_ProgramFiles,1,StrLen("C:\Program")) "Files\EverythingSDK"
	EverythingMod := DllCall("LoadLibrary", "Str", Folder . "\" . EverythingDll, "Ptr")
	if not EverythingMod
		throw EverythingDll " not found."
	GetResultPath:=EverythingDll . "\Everything_GetResultPath"
	GetResultFileName:=EverythingDll . "\Everything_GetResultFileName"
	GetResultAttributes:=EverythingDll . "\Everything_GetResultAttributes"
	
	EverythingResult:={_NewEnum:"EverythingSearch_ResultEnumerator",Count:"EverythingSearch_ResultCount"}
	EverythingSearch_ResultEnumerator:={Next:"EverythingSearch_ResultEnumeratorNext"}
	
	;initial state see: Everything_Reset
	;	https://www.voidtools.com/support/everything/sdk/everything_reset/
	
	if(IsFileMethod="RequestAttribute"){
		EVERYTHING_REQUEST_FILE_NAME:=0x00000001
		EVERYTHING_REQUEST_PATH:=0x00000002
		EVERYTHING_REQUEST_ATTRIBUTES:=0x00000100
		DllCall(EverythingDll . "\Everything_SetRequestFlags", "UInt"
		;	https://www.voidtools.com/support/everything/sdk/everything_setrequestflags/
			, EVERYTHING_REQUEST_FILE_NAME
			|EVERYTHING_REQUEST_PATH
			|EVERYTHING_REQUEST_ATTRIBUTES)
	}
	
	OnExit("EverythingSearch_OnExit")
;}

If (A_ScriptFullPath=A_LineFile){ ;test
	search:=EverythingDll
	search=regex:"(?<=^Every)th" regex:ing\d+ Files\
	;	RobertWork: C:\ProgramFiles\EverythingToolbar-0.5.2\Everything64.dll
	Loop{
		inputbox, search, Search in everything:, Cancel to clear input`, then exit.`nRegEx enabled.,, 300, 150,,,,,% search
		if(ErrorLevel)
			if(search="")
				ExitApp
			else
				search:=""
		else{
			results:=Search(search)
			count:=results.Count()
			for path,file in results{
				MsgBox % 0x4, Found,% A_Index "/" count ". Continue?`n"
					;	0x4: Yes/No
					. path
					. "`n"
					. (file?file:"<directory>")
				IfMsgBox, No
					break
			}
		}
	}
}


Search(search){
	global EverythingDll,IsFileMethod,EverythingResult,EverythingSearch_ResultCount
	DllCall(EverythingDll . "\Everything_SetSearch", "Str", search)
	;	fast when default (query mode 1)
	if not DllCall(EverythingDll . "\Everything_Query", "Int", True)
		throw "Failed."
	;~ DllCall(EverythingDll . "\Everything_SetRegex", "Int", enableRegex)
	EverythingSearch_ResultCount:=DllCall(EverythingDll . "\Everything_GetNumResults", "UInt")
	if not EverythingSearch_ResultCount
		return
	return EverythingResult
}
EverythingSearch_ResultCount(){
	global EverythingSearch_ResultCount
	return EverythingSearch_ResultCount
}
EverythingSearch_ResultEnumerator(){
	global EverythingResultIndex:=0,EverythingSearch_ResultEnumerator
	return EverythingSearch_ResultEnumerator
}
EverythingSearch_ResultEnumeratorNext(ByRef path,ByRef name:=""){
	static FILE_ATTRIBUTE_DIRECTORY:=0x10
	;	File Attribute Constants (WinNT.h) - Win32 apps | Microsoft Docs
	;		https://docs.microsoft.com/en-us/windows/win32/fileio/file-attribute-constants
	global EverythingDll,EverythingSearch_ResultCount,EverythingResultIndex,GetResultAttributes,GetResultPath,GetResultFileName,IsFileMethod
	if(not EverythingResultIndex<EverythingSearch_ResultCount)
		return
	
	folder:=DllCall(GetResultPath, "UInt", EverythingResultIndex, "Str")
	file:=DllCall(GetResultFileName, "UInt", EverythingResultIndex, "Str")
	;~ . " [" . DllCall(EverythingDll . "\Everything_GetResultExtension", "UInt", A_Index - 1, "Str") . "]"
	;~ . " [" . DllCall(EverythingDll . "\Everything_GetResultDateModified", "UInt", A_Index - 1, "Str") . "]"
	;	need EVERYTHING_REQUEST_*
	
	path:=folder "\" file
	if (IsFileMethod="RequestAttribute"){
		attribute:=DllCall(GetResultAttributes, "UInt", EverythingResultIndex, "UInt")
		isFile:=not attribute&FILE_ATTRIBUTE_DIRECTORY
	}else if(IsFileMethod="FileExist")
		isFile:=not InStr(FileExist(path),"D")
	name:=isFile?file:false	;is file
	EverythingResultIndex++
	return true
}
EverythingSearch_OnExit(){
	global EverythingDll,EverythingMod
	DllCall(EverythingDll . "\Everything_Reset")
	DllCall("FreeLibrary", "Ptr", EverythingMod)	
}