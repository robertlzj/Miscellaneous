#SingleInstance,Force
#NoEnv
#Include HotKey_WhenEditInSciTE.ahk
if(not A_IsAdmin and A_ScriptFullPath!=A_LineFile){
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
;	RunWaitOne, HandleSpaceInPath
#Include EverythingSearch.ahk
;	Search
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
				InputBox, OutputVar,,Source File Name: %sourceFileName% `n%prompt%Set Abstract Identifier (without extension),,,160,,,,,% Default
				referFileNameWithoutExt:=OutputVar
				if ErrorLevel ;cancel
					goto Abort
				referFolderPath:=sourceDirPath "\_ReferStorage_"
				referFilePath:=referFolderPath "\" referFileNameWithoutExt "." sourceFileExtension
				if not FileExist(referFilePath){
					prompt:=e
					break
				}
				prompt:="Identifier Name Exist.`n "
				Default:=referFileNameWithoutExt
			}
			Default:=e
			;{Move
				if not FileExist(referFolderPath)
					FileCreateDir, % referFolderPath
				moved:=false
				FileMove,% sourceFilePath,% referFilePath
				;	The destination directory must already exist
				if ErrorLevel{	;number of files that could not be moved due to an error
					MsgBox File not move. Last Error: %A_LastError%.`nFrom: %sourceFilePath%`nTo: %referFilePath%.
					;	0x3: The system cannot find the path specified.
					;	112: There is not enough space on the disk.
					goto Abort
				}
				moved:=true
			;}
			referFilePathWithQuotation:=HandleSpaceInPath(referFilePath)
			;~ MsgBox % (referFileNameWithoutExt=sourceFileName) "`n" referFileNameWithoutExt "`," sourceFileName	;test
			if(referFileNameWithoutExt!=sourceFileNameWithoutExt){
				;	;and not referFilePath~=("^""?\Q" sourceFileName "\E[·.]")
				;	;	\b wont work correctly on string like chinese?
				;	;	\b is equivalent to [a-zA-Z0-9_]
				MsgBox ,% 0x3|0x20,,Yes to change original file name to contain identifier?`nOr no to keep original and create an extra map file.
				IfMsgBox, Yes
					originalFilePath:=sourceDirPath "\" referFileNameWithoutExt "·" sourceFileName
				IfMsgBox, No
				{
					originalFilePath:=sourceFilePath
					extraMapFilePath:=sourceDirPath "\" sourceFileNameWithoutExt "·" (referFileNameWithoutExt=sourceFileNameWithoutExt?"":referFileNameWithoutExt) "." sourceFileExtension
					if FileExist(extraMapFilePath){
						MsgBox %extraMapFilePath% exist.
						goto Abort
					}
					HandleSpaceInPath(extraMapFilePath)
					RunWaitOne("ln --symbolic " . referFilePathWithQuotation . " " . extraMapFilePath)
					extraMapFilePath:=e
				}
				IfMsgBox, Cancel
					goto Abort
			}else
				originalFilePath:=sourceFilePath
			RunWaitOne("ln --symbolic " . referFilePathWithQuotation . " " . HandleSpaceInPath(originalFilePath))
			;~ referFilePath:=Trim(referFilePath,c)
			originalFilePath:=e
			Sleep 200
			Send  {F5}
			;~ MsgBox % sourceDirPath "\" referFileNameWithoutExt "." sourceFileExtension ;test
			OpenAndSelect(sourceDirPath,referFileNameWithoutExt "." sourceFileExtension)
		}else
			referFilePath:=targetFilePath
		targetFilePath:=e
	}else
		referFilePath:=sourceFilePath
	SplitPath, referFilePath , _referFileName, _referDirPath, referFileExtension, referFileNameWithoutExt
	FileAppend, % "referFilePath: " referFilePath . "`n",*
	referFilePathWithQuotation:=HandleSpaceInPath(referFilePath)
	return
Abort:
	if moved{	;cancel / move back
		;~ MsgBox,% referFilePath "`n" sourceFilePath	;test
		FileMove,% referFilePath,% sourceFilePath
		;~ MsgBox % ErrorLevel "`n" A_LastError	;test
		;	A_LastError:
		;		123: The filename, directory name, or volume label syntax is incorrect.
		moved:=false
	}
	referFilePath:=e
	Exit
!v::
	if not referFilePath
		Exit
	targetFolder:=Explorer_GetPath()
	;~ MsgBox % targetFolder	;test
	if not targetFolder
		Exit
	targetIndex:=e
	while true{
		targetFileName:=referFileNameWithoutExt . (targetIndex?("·" . targetIndex):e) . (referFileExtension?("." referFileExtension):e)
		targetFilePath:=targetFolder . targetFileName
		;~ MsgBox % targetFilePath	;test
		if not FileExist(targetFilePath)
			break
		targetIndex++
	}
	FileAppend, % "targetFilePath: " targetFilePath . "`n", *
	command:="ln --symbolic " . referFilePathWithQuotation . " " . HandleSpaceInPath(targetFilePath)
	;	shift upstream
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
	;~ Send  {F2}
	;~ Send  {F2}
	;~ Send  {F2}
	;~ MsgBox %targetFolder%`n%targetFileName%
	return
!z::
	data:=%getDataFunction%()
	if not FileExist(data)	;or multiple files then
		return
	sourceFilePath:=data
	SplitPath, sourceFilePath , sourceFileName, sourceDirPath, sourceFileExtension, sourceFileNameWithoutExt
	ouputs:=""
	results:=GetAllEntraces(sourceFilePath)
	target:=results.TargetPath
	;~ for path in results
	length:=results.Length()
	Loop % length
		ouputs.=results[A_Index] "`n"
	RTrim(results,"`n")
	MsgBox Target path "%target%".`nAnd its %length% entrance:`n%ouputs%
	return
	
ShellGetSelected(){
	folder:=Explorer_GetPath()
	file:=Explorer_GetSelected()
	return folder . file
}
GetAllEntraces_Core(id,targetPath,ByRef results){
	if((found:=Search(id " attrib:L")) and not results["_" id]){
		;	"_" id: avoid conflict with index
		;	"regex:""(?>·|^)" id "(?=·|\.|$)"" attrib:L"
		;		slow
		results["_" id]:=true
		for path_relate in found
			if(not results[path_relate]){
				results[path_relate]:=true
				if(targetPath=GetAbsoluteTarget(path_relate)){
					results.Push(path_relate)
					if RegExMatch(path_relate,"O).+\\(.+?)·" id "(?=·|.|$)",match){
						id_alias:=match[1]
						GetAllEntraces_Core(id_alias,targetPath,results)
					}
				}
			}
		}
}
GetAllEntraces(path,ByRef results:=""){
	if not FileExist(path)
		throw """%path%"" not a path."
	if not targetPath:=GetAbsoluteTarget(path)
		targetPath:=path
	if not RegExMatch(path,"O).+\\(.+?)(?=·|\.|$)",match)
		throw "should always find a name(id)."	;expect name like "·"
	id:=match[1]
	if not results{
		results:={TargetPath:targetPath,(targetPath):true}
	}
	GetAllEntraces_Core(id,targetPath,results)
	if(targetPath!=path)
		GetAllEntraces(targetPath,results)
	return results
}
#IfWinActive ReferLink.ahk ahk_class #32770 ahk_exe AutoHotkey.exe	;Set Abstract Identifier
!x::Send {Enter}	;use current file name

;----debug/test----
/* 
	#IfWinActive ReferLink.ahk ahk_class SciTEWindow ahk_exe SciTE.exe
	F3::
		Send ^s
		Reload
		return
	F2::ExitApp
 */
#IfWinActive