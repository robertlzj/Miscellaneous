#SingleInstance,Force
#NoEnv
if(not A_IsAdmin){
	;	see A_IsAdmin / Operating System and User Info / Built-in Variables / Variables and Expressions
	;	see Run as Administrator / Run[Wait]
	Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	;	could not debug..
	ExitApp
}
#Include dataFromToClipboard.ahk
#Include CheckIfIsSymlinkFileOrDirectoryOrNot.ahk
#Include Get paths of selected items in an explorer window.ahk
#Include ExplorerOpenAndSelect.ahk
#Include CommandLine.ahk
getDataFunction:=""
	;~ . "dataFromToClipboard"
	. "ShellGetSelected"
#IfWinActive ahk_exe explorer.exe
!c::
!x::
	data:=%getDataFunction%()
	if not FileExist(data)	;or multiple files then
		return
	if(A_ThisHotkey="!c")
		sourceFilePath:=data
	else{
		target:=GetAbsoluteTarget(data)
		if(not target){
			
		}
		sourceFilePath:=target
	}
	SplitPath, sourceFilePath , sourceFileName, sourceDirPath, sourceFileExtension, sourceFileNameWithoutExt
	FileAppend, % "sourceFilePath: " sourceFilePath . "`n",*
	if InStr(sourceFilePath," ")
		sourceFilePath:="""" . sourceFilePath . """"
	return
!v::
	targetFolder:=Explorer_GetPath()
	if not targetFolder
		return
	targetIndex:=""
	while true{
		targetFileName:=sourceFileNameWithoutExt . (targetIndex?("·" . targetIndex):"") . (sourceFileExtension?("." sourceFileExtension):"")
		targetFilePath:=targetFolder . targetFileName
		if not FileExist(targetFilePath)
			break
		targetIndex++
	}
	FileAppend, % "targetFilePath: " targetFilePath . "`n", *
	if InStr(targetFilePath," ")
		targetFilePath:="""" . targetFilePath . """"
	command:="ln --symbolic " . sourceFilePath . " " . targetFilePath
	;~ MsgBox % command
	;	MsgBox % IsAdmin_TestByWScriptCommand() "," A_IsAdmin
	;	;	test result conflict - false, true (0,1).
	;~ resutl:=RunWaitOne(command)
	;	symbolic links can only be successfully created from an administrative command prompt. ln.exe will fail on symbolic links from a normal command prompt!
	;	/ --symbolic Symbolic Links / ln - command line hardlinks
	MsgBox ,,,% resutl
	FileAppend, % resutl, *
	;	failed, get:
	;	ln 2.933
	OpenAndSelect(targetFolder,targetFileName)
	return

ShellGetSelected(){
	folder:=Explorer_GetPath()
	file:=Explorer_GetSelected()
	return folder . file
}
;----debug/test----
#IfWinActive ReferLink.ahk ahk_class SciTEWindow ahk_exe SciTE.exe
F1::Reload
F2::ExitApp
#IfWinActive