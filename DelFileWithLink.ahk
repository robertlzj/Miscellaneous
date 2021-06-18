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
/* 
	#IfWinActive DelFileWithLink.ahk  ahk_class SciTEWindow ahk_exe SciTE.exe
	$F3::
		Send ^s
		Reload
		return
	$F2::ExitApp
 */
#If not A_CaretX and ((WinActive("ahk_exe explorer.exe") or WinActive("ahk_class #32770")))
$+Del::	;del file(s), handle hard link entrance.
$Del::	;del file(s), handle hard link entrance.
	modifer:=GetKeyState("shift","P")?"+":""
	explorer:=WinExist("A")
	folder:=Explorer_GetPath()
	if not folder
		return
	;	contain "\"
	selectfiles:=Explorer_GetSelected()
	if not selectfiles
		return
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
			MsgBox , % 0x3|0x20,,Path "%path%" is link target.`nYes to Remove all entrance (there is another comfirm)`nNo to keep symlinks (brokean)?
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
	WinWaitActive, ɾ�� ahk_class #32770 ahk_exe explorer.exe,,1
	;	ɾ��: ɾ���ļ�/ɾ�������Ŀ
	if ErrorLevel
		Exit
	WinGetText, text
	;	Text:
	;		ȷʵҪ�Ѵ��ļ��������վ��?
	;		ȷʵҪ���� X ���ƶ�������վ��?
	;		ȷʵҪ�����Ե�ɾ�����ļ���?
	;		ȷʵҪ����ɾ���� X ����?
	WinWaitClose
	pathsToDelete:=LTrim(pathsToDelete,"`n")
	;~ MsgBox % "----`n" pathsToDelete "`n----"	;test
	if FileExist(path)	;operate canceled
		Exit
	if pathsToDelete{
		;relate: https://www.google.com.hk/search?q=delete+to+recycle+bin+autohotkey&newwindow=1&safe=strict&sxsrf=ALeKk03i8wUwVlF7BB6CqwsJPbDbbcpMgg%3A1623758107149&source=hp&ei=G5XIYJWUBqiRr7wPh5W1gAQ&iflsig=AINFCbYAAAAAYMijK3bUUDe77mo6hek-udaAL88MqqRr&oq=delete+to+recycle+bin+autohotkey&gs_lcp=Cgdnd3Mtd2l6EAM6BwgjEOoCECc6AggAOgUIABDLAToECAAQHjoGCAAQBRAeOgYIABAIEB46BQghEKABOgcIIRAKEKABUJIwWIubAWCFqAFoAXAAeAGAAdQGiAHRQpIBDjAuMTYuOS4zLjEuMi4xmAEAoAEBqgEHZ3dzLXdperABCg&sclient=gws-wiz&ved=0ahUKEwjVjbOpypnxAhWoyIsBHYdKDUAQ4dUDCAc&uact=5
		if text~="����վ"
			Loop, Parse, pathsToDelete, `n, `r
				FileRecycle, % A_LoopField
		else if text~="����"
			Loop, Parse, pathsToDelete, `n, `r
				FileDelete, % A_LoopField
		else
			throw "Error, unhandle case."
	}
	return