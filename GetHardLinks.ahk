#SingleInstance,Force
#NoEnv
;From: showlink.ahk https://www.autohotkey.com/boards/viewtopic.php?t=86940&p=382043
; enumerate all locations of file
; prepends drive letter before the output paths to make them whole :)
; todo: take advantage of buflen being set to the required length
; https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstfilenamew
; https://docs.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findnextfilenamew
GetHardLinks(path_init)
{
	static ERROR_MORE_DATA := 234
	static MAX_PATH := 260
	
	if (SubStr(path_init, 2, 2) != ":\")	; gotcha: 2 is the length, not the end
		throw "GetHardLinks(path) \\ path (%path_init%) is not complete"
	
	path_init:=Format("{:U}",path_init)
	
	root := SubStr(path_init, 1, 2)
	paths := {}
	
	buflen := MAX_PATH
	VarSetCapacity(linkname,buflen)
	handle := DllCall("FindFirstFileNameW"
		,"WStr", path_init
		,"UInt", 0
		,"UInt*", buflen
		,"WStr", linkname)
	
	if (A_LastError == ERROR_MORE_DATA)
		throw "ListLinks: ERROR_MORE_DATA, 260 was not enough..."
	if (handle == 0xffffffff)
		throw "ListLinks: FindFirstFileNameW failed"
	
	try
	{
		Loop
		{
			path:=root linkname
			if Format("{:U}",path)!=path_init
				paths[path]:=A_Index
			
			buflen := MAX_PATH
			VarSetCapacity(linkname,buflen)
			more := DllCall("FindNextFileNameW"
			,"UInt", handle
			,"UInt*", buflen
			,"WStr", linkname)
		} until (!more)
		
		if (A_LastError == ERROR_MORE_DATA)
			throw "ListLinks: ERROR_MORE_DATA, 260 was not enough..."
	} finally
		DllCall("FindClose", "UInt", handle)
	
	return paths.Count()>0?paths:false
}

If (A_ScriptFullPath=A_LineFile){	;test
	paths:=""
	target:=A_Args[1]
	target:="F:\link test\H.txt"
	;~ target:="F:\link test\N.txt"	;single-instance
	if not target
		throw "No target specified"
	hardLinks:=GetHardLinks(target)
	if not hardLinks
		FileAppend, target (%target%) is single-instance, *
	else{
		for path in hardLinks
			paths.=path "`r`n"
		paths:=RTrim(paths,"`r`n")
		FileAppend, % paths, *
	}
}