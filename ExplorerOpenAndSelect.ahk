;[Func] Open Folder With Pre-Selected Files - Scripts and Functions - AutoHotkey Community
;	https://autohotkey.com/board/topic/83988-func-open-folder-with-pre-selected-files/
OpenAndSelect(sPath, Files*)
{
	; Make sure path has a trailing \
	if (SubStr(sPath, 0, 1) <> "\")
		sPath .= "\"
	
	; Get a pointer to ID list (pidl) for the path
	DllCall("shell32\SHParseDisplayName", "str", sPath, "Ptr", 0, "Ptr*", FolderPidl, "Uint", 0, "Uint*", 0)
	
	count:=Files.MaxIndex()
	; create a C type array and store each file name pidl
	VarSetCapacity(PidlArray,  count?count* A_PtrSize:0, 0)
	for i in Files {
		DllCall("shell32\SHParseDisplayName", "str", sPath . Files[i], "Ptr", 0, "Ptr*", ItemPidl, "Uint", 0, "Uint*", 0)
		NumPut(ItemPidl, PidlArray, (i - 1) * A_PtrSize) 
	}
	
	DllCall("shell32\SHOpenFolderAndSelectItems", "Ptr", FolderPidl, "UInt", count?count:0, "Ptr", &PidlArray, "Int", 0)
	
	; Free all of the pidl memory
	for i in Files 
		CoTaskMemFree(NumGet(PidlArray, (i - 1) * A_PtrSize))
	CoTaskMemFree(FolderPidl)
}

CoTaskMemFree(pv)
{
   Return   DllCall("ole32\CoTaskMemFree", "Ptr", pv)
}

if(A_ScriptFullPath=A_LineFile){	
	;A_Args.Length()<1
	if(A_Args.Length()=0) ;test
		OpenAndSelect("C:\1","1.txt","2.txt")
	else{
		if(not A_Args.Length()>=2)
			throw "lack of args."
		OpenAndSelect(A_Args*)
	}
}else{
	;call OpenAndSelect(..) from upper process
}