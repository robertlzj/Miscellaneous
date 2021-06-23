;deprecate. see phone.ahk \ GetSelectPath()
#SingleInstance,Force
#NoEnv
global pathOfSelected:="File" ;or "FolderAndFile"
global baseLength
If (A_ScriptFullPath=A_LineFile){
	Hotkey,F1,F1_GetPathsOfSelectedItemsInAnExplorerWindow
	Hotkey,F2,F2_GetPathsOfSelectedItemsInAnExplorerWindow
	Hotkey, IfWinActive, ahk_exe SciTE.exe
	Hotkey,F1,Exit_GetPathsOfSelectedItemsInAnExplorerWindow
	Hotkey, IfWinActive
	return
Exit_GetPathsOfSelectedItemsInAnExplorerWindow:
	ExitApp
F1_GetPathsOfSelectedItemsInAnExplorerWindow:
	ControlGet, selectedFiles, List, selected, SysListView321, A
	FileAppend, % selectedFiles, *
	;~ MsgBox, % selectedFiles
	return

;Get paths of selected items in an explorer window - Scripts and Functions - AutoHotkey Community
;	https://autohotkey.com/board/topic/60985-get-paths-of-selected-items-in-an-explorer-window/
F2_GetPathsOfSelectedItemsInAnExplorerWindow:
	path := Explorer_GetPath()
	;~ all := Explorer_GetAll()
	sel := Explorer_GetSelected()
	;~ FileAppend, % "Path:`n" path "`nAll:`n" all "`nSel:`n" sel "`n", *
	MsgBox, % "Path:`n" path "`nAll:`n" all "`nSel:`n" sel "`n"
	;1: normal (folder/file) path
	;	Path (Folder): C:\Folder
	;	All/Sel (File): File.txt
	;2: Recycle Bin / this computer
	;	Path (Folder): 
	;	All/Sel (File):
	;		this computer:
	;			C:\Users\XXX
	;			::{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}\::{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}
	;			C:\	;Volumn
	;		Recycle Bin:
	;			C:\$Recycle.Bin\S-1-5-21-XXXXXXXXX-XXXXXXXXXX-XXXXXXXXXX-XXXX\$RXXXXXX.txt	;not real name
	return
}
/*
	Library for getting info from a specific explorer window (if window handle not specified, the currently active
	window will be used).  Requires AHK_L or similar.  Works with the desktop.  Does not currently work with save
	dialogs and such.
	
	
	Explorer_GetSelected(hwnd="")   - paths of target window's selected items
	Explorer_GetAll(hwnd="")        - paths of all items in the target window's folder
	Explorer_GetPath(hwnd="")       - path of target window's folder
	
	example:
		F1::
			path := Explorer_GetPath()
			all := Explorer_GetAll()
			sel := Explorer_GetSelected()
			MsgBox % path
			MsgBox % all
			MsgBox % sel
		return
	
	Joshua A. Kinnison
	2011-04-27, 16:12
*/

Explorer_GetPath(hwnd="")
{
	if !(window := Explorer_GetWindow(hwnd))
		return ErrorLevel := "ERROR"
	if (window="desktop")
		return A_Desktop . "\"
	path := window.LocationURL
	;	maybe empty (in this computer, Recycle Bin)
	if path{
		path := RegExReplace(path, "ftp://.*@","ftp://")
		StringReplace, path, path, file:///
		StringReplace, path, path, /, \, All 
		
		; thanks to polyethene
		Loop
			If RegExMatch(path, "i)(?<=%)[\da-f]{1,2}", hex)
				StringReplace, path, path, `%%hex%, % Chr("0x" . hex), All
			Else Break
		path.="\"
		baseLength:=StrLen(path)+1
	}else
		baseLength:=1
	return path
}
Explorer_GetAll(hwnd="")
{
	return Explorer_Get(hwnd)
}
Explorer_GetSelected(hwnd="")
{	;deprecate. see phone.ahk \ GetSelectPath()
	return Explorer_Get(hwnd,true)
	;	only contain file name (not contain folder)
	;	see Explorer_GetPath()
}

Explorer_GetWindow(hwnd="")
{
	; thanks to jethrow for some pointers here
    WinGet, process, processName, % "ahk_id" hwnd := hwnd? hwnd:WinExist("A")
    WinGetClass class, ahk_id %hwnd%
	
	if (process!="explorer.exe")
		return
	if (class ~= "(Cabinet|Explore)WClass")
	{
		for window in ComObjCreate("Shell.Application").Windows
			;	may miss some window (if explorer crashed?)
			if (window.hwnd==hwnd)
				return window
	}
	else if (class ~= "Progman|WorkerW") 
		return "desktop" ; desktop found
}
Explorer_Get(hwnd="",selection=false)
{
	if !(window := Explorer_GetWindow(hwnd))
		return ErrorLevel := "ERROR"
	if (window="desktop")
	{
		ControlGet, hwWindow, HWND,, SysListView321, ahk_class Progman
		if !hwWindow ; #D mode
			ControlGet, hwWindow, HWND,, SysListView321, A
		ControlGet, files, List, % ( selection ? "Selected":"") "Col1",,ahk_id %hwWindow%
		base := SubStr(A_Desktop,0,1)=="\" ? SubStr(A_Desktop,1,-1) : A_Desktop . "\"
		Loop, Parse, files, `n, `r
		{
			IfExist %  base .  A_LoopField	; ignore special icons like Computer (at least for now)
				ret .= (pathOfSelected="FolderAndFile"?base:"") . A_LoopField "`n"
		}
	}
	else
	{
		if selection
			collection := window.document.SelectedItems
		else	;all
			collection := window.document.Folder.Items
		for item in collection{
			path:=item.Path
			break
		}
		if not baseLength{
			RegExMatch(path,"P).*\\",baseLength)
			baseLength++
		}
		for item in collection{
			;	item: FolderItem object (Shldisp.h) - Win32 apps | Microsoft Docs
			;		https://docs.microsoft.com/en-us/windows/win32/shell/folderitem
			path:=item.Path
			;	Contains the item's full path and name.
			;		https://docs.microsoft.com/en-us/windows/win32/shell/folderitem-path
			ret .= (pathOfSelected="File" ? SubStr(path,baseLength) : path) . "`n"
		}
		if selection
			baseLength:=0
	}
	return Trim(ret,"`n")
}