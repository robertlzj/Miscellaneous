#SingleInstance,Force
#NoEnv
if(not A_IsAdmin){
	;	see A_IsAdmin / Operating System and User Info / Built-in Variables / Variables and Expressions
	;	see Run as Administrator / Run[Wait]
	Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
	;	could not debug..
	ExitApp
}
Menu, Tray, Icon, ReferLink.ico
#Include dataFromToClipboard.ahk
#Include CheckIfIsSymlinkFileOrDirectoryOrNot.ahk
#Include Get paths of selected items in an explorer window.ahk
#Include ExplorerOpenAndSelect.ahk
;	OpenAndSelect
#Include CommandLine.ahk
;	RunWaitOne
getDataFunction:=""
	;~ . "dataFromToClipboard"
	. "ShellGetSelected"
c:=""""
e:=""
#IfWinActive ahk_exe explorer.exe
~^c::
!c::
!x::
	data:=%getDataFunction%()
	if not FileExist(data)	;or multiple files then
		return
	sourceFilePath:=data
	SplitPath, sourceFilePath , sourceFileName, sourceDirPath, sourceFileExtension, sourceFileNameWithoutExt
	;	The final backslash is not included even if the file is located in a drive's root directory.
	if(A_ThisHotkey="!x"){
		targetFilePath:=GetAbsoluteTarget(sourceFilePath)
		if(not targetFilePath){
			Default:=sourceFileNameWithoutExt
			while true
			{
				InputBox, OutputVar,,Source File Name: %sourceFileName% `n%prompt%Set Abstract Identifier Name,,,160,,,,,% Default
				referFileName:=OutputVar
				if ErrorLevel ;cancel
					goto Abort
				referFolderPath:=sourceDirPath "\_ReferStorage_"
				referFilePath:=referFolderPath "\" referFileName "." sourceFileExtension
				if not FileExist(referFilePath){
					prompt:=e
					break
				}
				prompt:="Identifier Name Exist.`n "
				Default:=referFileName
			}
			Default:=e
			if not FileExist(referFolderPath)
				FileCreateDir, % referFolderPath
			FileMove,% sourceFilePath,% referFilePath
			;	The destination directory must already exist
			if ErrorLevel{	;number of files that could not be moved due to an error
				MsgBox File not move. Last Error: %A_LastError%.`nFrom: %sourceFilePath%`nTo: %referFilePath%.
				;	0x3: The system cannot find the path specified.
				goto Abort
			}
			HandleSpaceInPath(referFilePath)
			if not sourceFileName~=("^""?" referFilePath "·?\b"){
				MsgBox ,% 0x3|0x20,,Yes to change original file name to contain identifier?`nOr no to keep original and create an extra map file.
				IfMsgBox, Yes
					originalFilePath:=sourceDirPath "\" referFileName "·" sourceFileName
				IfMsgBox, No
				{
					originalFilePath:=sourceFilePath
					extraMapFilePath:=sourceDirPath "\" sourceFileNameWithoutExt "·" (referFileName=sourceFileNameWithoutExt?"":referFileName) "." sourceFileExtension
					if FileExist(extraMapFilePath){
						MsgBox %extraMapFilePath% exist.
						goto Abort
					}
					HandleSpaceInPath(extraMapFilePath)
					RunWaitOne("ln --symbolic " . referFilePath . " " . extraMapFilePath)
					extraMapFilePath:=e
				}
				IfMsgBox, Cancel
					goto Abort
			}else
				originalFilePath:=sourceFilePath
			HandleSpaceInPath(originalFilePath)
			RunWaitOne("ln --symbolic " . referFilePath . " " . originalFilePath)
			referFilePath:=Trim(referFilePath,c)
			originalFilePath:=e
		}else
			referFilePath:=targetFilePath
		targetFilePath:=e
	}else
		referFilePath:=sourceFilePath
	SplitPath, referFilePath , _referFileName, _referDirPath, referFileExtension, referFileNameWithoutExt
	FileAppend, % "referFilePath: " referFilePath . "`n",*
	HandleSpaceInPath(referFilePath)
	return
Abort:
	referFilePath:=e
	Exit
!v::
	if not referFilePath
		Exit
	targetFolder:=Explorer_GetPath()
	if not targetFolder
		Exit
	targetIndex:=e
	while true{
		targetFileName:=referFileNameWithoutExt . (targetIndex?("·" . targetIndex):e) . (referFileExtension?("." referFileExtension):e)
		targetFilePath:=targetFolder . targetFileName
		if not FileExist(targetFilePath)
			break
		targetIndex++
	}
	FileAppend, % "targetFilePath: " targetFilePath . "`n", *
	HandleSpaceInPath(targetFilePath)
	;	HandleSpaceInPath(referFilePath)
	;	shift upstream
	command:="ln --symbolic " . referFilePath . " " . targetFilePath
	targetFilePath:=Trim(targetFilePath,c)
	;~ MsgBox % command
	;	MsgBox % IsAdmin_TestByWScriptCommand() "," A_IsAdmin
	;	;	test result conflict - false, true (0,1).
	resutl:=RunWaitOne(command)
	;	symbolic links can only be successfully created from an administrative command prompt. ln.exe will fail on symbolic links from a normal command prompt!
	;	/ --symbolic Symbolic Links / ln - command line hardlinks
	;~ MsgBox ,,,% resutl
	FileAppend, % "Command Return Value: " resutl, *	;for test/debug
	;	failed, get:
	;	ln 2.933
	;	success on Robert Work
	
	;	while not FileExist(targetFilePath)
	;		Sleep 200
	;not needed.
	
	;	Send {Alt up}
	;	;	if there is no interval, then source file will still be selected.
	;	;		not related with Alt, even alt is held down and "v" is released.
	;need update, use {F5} or Sleep for a while
	;	Sleep 1000
	Send  {F5}
	;~ OpenAndSelect(targetFolder,"")
	OpenAndSelect(targetFolder,targetFileName)
	Send  {F2}
	;~ MsgBox %targetFolder%`n%targetFileName%
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

HandleSpaceInPath(ByRef path){
	global c
	if(not path~="^"".*""$" and InStr(path," "))
		path:=c . path . c
}