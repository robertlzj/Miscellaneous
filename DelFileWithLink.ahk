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
		}else if(not (tartgetPath:=GetAbsoluteTarget(path))){	;check symlink target / entrance
			if(entrances:=GetAllEntraces(path)){	;then is symlink destination
				MsgBox , % 0x3|0x20,,Path "%path%" is link target.`nYes to Remove all entrance`, No to keep symlinks (brokean)?
				;	0x3: Yes/No/Cancel
				;	0x20:	Icon Question
				IfMsgBox, Cancel
					Exit
				IfMsgBox, Yes
				{
					for entrance in entrances
						symlinks.="`n" entrance
					MsgBox, % 0x1|0x20,,Confirm symlinks to be delete.%symlinks%
					;	0x1: OK/Cancel
					;	0x20:	Icon Question
					IfMsgBox, Cancel
						Exit
					pathsToDelete.=symlinks
				}
			}
		}else{	;is entrance which have tartgetPath
			if not (RegExMatch(targetPath,"O).+\\(.+?)(?=��|\.|$)",match))
				throw "should always find id."	;expect name like "��"
			targetPath_id:=match[1]
			if not (RegExMatch(A_LoopField,"O)(.+?)(?=��).*?(?<=��)\Q" targetPath_id "\E(?=��|\.|$)",match))
				;	alias �� id
				throw "should always find id."	;expect name like "��"
			path_id:=match[1]
			if(path_id!=targetPath_id){	;is sub entrance
				MsgBox, % 0x3|0x20,,Path "%path%" has alias id "%path_id%".`nYes to Remove all sub entrance`, No to keep symlinks (brokean)?
				;	0x3: Yes/No/Cancel
				;	0x20:	Icon Question
				IfMsgBox, Cancel
					Exit
				IfMsgBox, Yes
				{
					entrances:=GetAllEntraces(path,folder)
					for entrance in entrances
						symlinks.="`n" entrance
					Loop, Parse, symlinks, `n
						if(A_LoopField~=("\Q" folder "\E" ))
				}
			}
		}
			removeSymlink:=""
			for path_relate in found
				if(path=GetAbsoluteTarget(path_relate))
					if(not removeSymlink){
						MsgBox , % 0x3|0x20,,File "%A_LoopField%" is link target (such from "%path%").`nYes to Remove all`, No to keep symlinks (brokean)?
						;	0x3: Yes/No/Cancel
						;	0x20:	Icon Question
						IfMsgBox, Cancel
							Exit
						IfMsgBox, No
							break
						removeSymlink:=path_relate
					}else ;remove all
						removeSymlink.="`n" path_relate
			if(removeSymlink){
				MsgBox, % 0x1|0x20,,Confirm to remove all?`nlink target: "%A_LoopField%" `nsymlink:`n%removeSymlink%
				;	0x1: OK/Cancel
				IfMsgBox, Cancel
					Exit
			}
		}
	if(symlinks.Count()>0){
		path_targets:=""
		while(path:=symlinks.RemoveAt(1)){
			targetPath:=symlinks[path]
			path_targets.="`n""" path """->""" targetPath """"
		}
		path_targets:=RTrim(path_targets,"`n")
		MsgBox, % 0x1|0x20,,There are symlinks.`nContinue?%path_targets%
		;	0x1: OK/Cancel
		;	0x20:	Icon Question
		IfMsgBox, Cancel
			Exit
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