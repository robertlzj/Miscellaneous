;i need help, how can i check a file is a "Symlink" file - Ask for Help - AutoHotkey Community
#SingleInstance, Force
;https://autohotkey.com/board/topic/116161-i-need-help-how-can-i-check-a-file-is-a-symlink-file/page-2#entry671220
SetBatchLines -1
ComObjError(false)

;----test----
;~ symlink=symlink_Shell
symlink=symlink_Cmd
previous:=Clipboard
Loop{
	InputBox, OutputVar_file, Test, Input file/folder path to check,,,180,,,,,% previous
	if ErrorLevel
		ExitApp
	previous:=OutputVar_file:=Trim(OutputVar_file,"""")
	if not FileExist(OutputVar_file)
		continue
	if %symlink%(OutputVar_file,target,type)
		MsgBox % OutputVar_file " is a symlink.`nTarget: " target "`nType: " type
	else
		MsgBox "%OutputVar_file%" is not a symlink
}
return
;https://autohotkey.com/board/topic/116161-i-need-help-how-can-i-check-a-file-is-a-symlink-file/page-2#entry671199
symlink_Shell(filepath,ByRef target="", ByRef type="")
{
	SplitPath, filepath , FileName, DirPath,
	objShell :=   ComObjCreate("Shell.Application")
	objFolder :=   objShell.NameSpace(DirPath)      ;set the directry path
	objFolderItem :=   objFolder.ParseName(FileName)   ;set the file name
	att := objFolder.GetDetailsOf(objFolderItem, 6)
	;	6: attributes (see iColumn bellow)
	;	L: Link?
	status := objFolder.GetDetailsOf(objFolderItem, 202)
	;	202: link status (see iColumn bellow)
	;	"Î´½âÎö¡° test from symlink or normal file / folder
	target := objFolder.GetDetailsOf(objFolderItem, 203)
	;	203: Link target (absolute) (see iColumn bellow)
	;iColumn:
	;	Folder.GetDetailsOf method (Shlobj\_core.h) - Win32 apps | Microsoft Docs
	;		https://docs.microsoft.com/en-us/windows/win32/shell/folder-getdetailsof
	;	c# - What options are available for Shell32.Folder.GetDetailsOf(..,..)? - Stack Overflow
	;		https://stackoverflow.com/questions/22382010/what-options-are-available-for-shell32-folder-getdetailsof
	if (att="AL")
		type:="File"
	else if (att="DL")
		type := "Folder"
	;else assert(att="A")
	if (att="AL" or att="DL")
		return 1
	else
		return 0
}
;	https://autohotkey.com/board/topic/116161-i-need-help-how-can-i-check-a-file-is-a-symlink-file/page-2#entry671733
symlink_Cmd(filepath,ByRef target="", ByRef type="")
{
	if RegExMatch(filepath,"^\w:\\?$") ;returns 0 if it is a root directory
		return 0
	SplitPath, filepath , fn, pdir
	dhw := A_DetectHiddenWindows
	DetectHiddenWindows On
	Run "%ComSpec%" /k,, Hide, pid
	while !(hConsole := WinExist("ahk_pid" pid))
		Sleep 10
	DllCall("AttachConsole", "UInt", pid)
	DetectHiddenWindows %dhw%
	objShell := ComObjCreate("WScript.Shell")
	objExec := objShell.Exec(comspec " /c dir /al """ (InStr(FileExist(filepath),"D") ? pdir "\" : filepath) """")
	While !objExec.Status
		Sleep 100
	cmd_result := objExec.StdOut.ReadAll()
	DllCall("FreeConsole")
	Process Exist, %pid%
	if (ErrorLevel == pid)
		Process Close, %pid%
	if RegExMatch(cmd_result,"<(.+?)>.*?\Q" fn "\E.*?\[(.+?)\]",m)
	{
		type:=m1, target:=m2
		;	target: original (maybe relative)
		if (type="SYMLINK")
			type := "File"
		else if (type="SYMLINKD")
			type := "Directory"
		return 1
	}
	else
		return 0
}