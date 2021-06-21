DelFileWithLink_StandAlone:=A_ScriptFullPath=A_LineFile
if(DelFileWithLink_StandAlone){
	Menu, Tray, Icon, % SubStr(A_ScriptName,1,-3) "ico"
	Hotkey, If, not WinActive("ahk_exe explorer.exe") && (WinActive("删除文件 ahk_class #32770") || WinActive("删除多个项目 ahk_class #32770"))
	Hotkey, $Del, DelFileWithLink_$Del
	Hotkey, If, not A_CaretX && (WinActive("ahk_exe explorer.exe") || (not WinActive("删除") && WinActive("ahk_class #32770")))
	Hotkey, $+Del, DelFileWithLink_$+Del
	Hotkey, $Del, DelFileWithLink_$Del_2
	Hotkey, If
}
#Include GetHardLinks.ahk
;	GetHardLinks
#Include Get paths of selected items in an explorer window.ahk
;	Explorer_GetSelected
#Include CheckIfIsSymlinkFileOrDirectoryOrNot.ahk
;	GetAbsoluteTarget()
#Include HotKey_WhenEditInSciTE.ahk
#Include EverythingSearch.ahk
;	Search()
#Include ReferLink.ahk
;	GetAllEntraces()
goto DelFileWithLink_End

/* 职责，
		a. 对explorer.exe，触发系统的删除对话框
		b. 对非explorer.exe，在其中触发DelFileWithLink_ExternalTrigger，
		c. 对非explorer.exe，在系统的删除对话框下，由Delete触发
*/
#If not WinActive("ahk_exe explorer.exe") && (WinActive("删除文件 ahk_class #32770") || WinActive("删除多个项目 ahk_class #32770"))	;{
;	"删除文件" / "删除多个项目"
;	standard delete dialog invoked by other exe (like potplayer / everything)
DelFileWithLink_$Del:	;{
DelFileWithLink_ExternalTrigger:
	if WinActive("删除多个项目 ahk_class #32770")
		throw "Cant detect file path to be delete, when multiple selection outside explorer.exe"
	explorer:=WinExist("A")
	ControlGetText, fileToBeDelete, Static4
	;	"Static4": file name to be delete.
	;MsgBox file to be delete is: %Output%	;debug
	if not ((founds:=Search("wfn:" fileToBeDelete)) and (count:=founds.Count())=1){
		MsgBox There are multiple files (%count%). Cant detect which one is being delete.
		return
	}
	_2:=(_1:=founds._NewEnum()).next(path)
	;	;selectfiles:=can't founds[1]
	RegExMatch(path,"O)(.+\\)(.+?)$",output)
	folder:=output[1],selectfiles:=output[2]
	;~ MsgBox Try to delete %folder%, %selectfiles%	;test
	goto DelFileWithLink_HandleDelete	;}
;}
#If not A_CaretX && (WinActive("ahk_exe explorer.exe") || (not WinActive("删除") && WinActive("ahk_class #32770")))
;	#32770: open / save..
DelFileWithLink_$+Del:	;del file(s), handle hard link entrance.
DelFileWithLink_$Del_2:	;{
	modifer:=GetKeyState("shift","P")?"+":""
	explorer:=WinExist("A")
	folder:=Explorer_GetPath()
	if(not folder or folder="ERROR")
		return
	;	contain "\"
	selectfiles:=Explorer_GetSelected()
	if not selectfiles
		return
DelFileWithLink_HandleDelete:	;{
	pathsToDelete:=path:=targetPath:=symlinks:=""
	Loop, Parse, % selectfiles,`n, `r
		if (path:=folder A_LoopField) && hardLinks:=GetHardLinks(path){
			single:=hardLinks.Count()=1
			be:=single?"is":"are"
			plural:=single?"":"s"
			entrances:=""
			for path_hardlink in hardLinks
				entrances.="`n" path_hardlink
			MsgBox , % 0x3|0x20,, File "%A_LoopField%" is hard link, delete all entrance?`n`nOther entrance%plural%: %entrances%
			;	0x3: Yes/No/Cancel
			;	0x20:	Icon Question
			IfMsgBox, Yes
				pathsToDelete.=entrances
			IfMsgBox, Cancel
				Exit
		}else if(entrances:=GetAllEntraces(path)){	;check if selection is source (destination) of symlink
			MsgBox , % 0x3|0x20,,Path "%path%" is link target.`nYes to Remove all entrance (there is another comfirm)`nNo [Esc] to keep symlinks (brokean)?
			;	0x3: Yes/No/Cancel
			;	0x20:	Icon Question
			IfMsgBox, Cancel
				Exit
			IfMsgBox, Yes
			{
				Loop % entrances.Length()
					symlinks.="`n" (entrance:=entrances[A_Index])
				MsgBox, % 0x1|0x20,,Confirm symlinks to be delete.%symlinks%
				;	0x1: OK/Cancel
				;	0x20:	Icon Question
				IfMsgBox, Cancel
					Exit
				pathsToDelete.=symlinks
			}
		}
	WinActivate, ahk_id %explorer%
	WinWaitActive
	Send %modifer%{Del}
	WinWaitActive, 删除 ahk_class #32770,,1
	;	"ahk_exe explorer.exe" maybe "potplayer.exe"
	;	删除: 删除文件/删除多个项目
	if ErrorLevel
		Exit
	WinGetText, text
	;	Text:
	;		确实要把此文件放入回收站吗?
	;		确实要将这 X 项移动到回收站吗?
	;		确实要永久性地删除此文件吗?
	;		确实要永久删除这 X 项吗?
	WinWaitClose
	pathsToDelete:=LTrim(pathsToDelete,"`n")
	;~ MsgBox % "----`n" pathsToDelete "`n----"	;test
	if FileExist(path)	;operate canceled
		Exit
	if pathsToDelete{
		;relate: https://www.google.com.hk/search?q=delete+to+recycle+bin+autohotkey&newwindow=1&safe=strict&sxsrf=ALeKk03i8wUwVlF7BB6CqwsJPbDbbcpMgg%3A1623758107149&source=hp&ei=G5XIYJWUBqiRr7wPh5W1gAQ&iflsig=AINFCbYAAAAAYMijK3bUUDe77mo6hek-udaAL88MqqRr&oq=delete+to+recycle+bin+autohotkey&gs_lcp=Cgdnd3Mtd2l6EAM6BwgjEOoCECc6AggAOgUIABDLAToECAAQHjoGCAAQBRAeOgYIABAIEB46BQghEKABOgcIIRAKEKABUJIwWIubAWCFqAFoAXAAeAGAAdQGiAHRQpIBDjAuMTYuOS4zLjEuMi4xmAEAoAEBqgEHZ3dzLXdperABCg&sclient=gws-wiz&ved=0ahUKEwjVjbOpypnxAhWoyIsBHYdKDUAQ4dUDCAc&uact=5
		if text~="回收站"
			Loop, Parse, pathsToDelete, `n, `r
				FileRecycle, % A_LoopField
		else if text~="永久"
			Loop, Parse, pathsToDelete, `n, `r
				FileDelete, % A_LoopField
		else
			throw "Error, unhandle case."
	}
	return	;}
	;}
DelFileWithLink_End:
_:=_