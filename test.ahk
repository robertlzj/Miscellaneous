#NoEnv
#SingleInstance,Force
#Include HotKey_WhenEditInSciTE.ahk

if(SoundPlay){
	SoundPlay,*-1	;success
	Input, _, L1
	SoundPlay,*16	;Hand (stop/error)
	Input, _, L1
	SoundPlay,*32	;Question	no effect
	Input, _, L1
	SoundPlay,*48	;Exclamation	same as success
	Input, _, L1
	SoundPlay,*64	;Asterisk (info)	same as success
	Input, _, L1
}
if(AssignWithinCommaInRuntime)
	MsgBox % Max(a:=1,b:=a+1)	;2
if(CouldConcateWithComma){
	if(true)
		a:=1,b:=2
	MsgBox % a ", " b
}
if(ErrorByRefWithDefaultWontPassParameter){
	;	recursive ByRef with empty/default input wont pass correct parameter
	;	https://www.autohotkey.com/boards/viewtopic.php?f=14&t=91727
	f(ByRef p:=""){
		if not p	;endless loop
			p:=0
		if(p++<2)
			f(p)
		return p
	}
	MsgBox % f()
}
if(RecursiveInvokeWithByRef){
	/* 
	f(ByRef o){
		FileAppend, % o.f, *
		if(o.f++<2)
			f(o)
	}
	g(ByRef o:=""){
		o:={f:0}
		f(o)
	}
	if(BothWorkCorrectly)
		g()
	else
		f(o)
	*/
}
if(IndentAndFold){
	{
		a:=1
	}	b:=2
	MsgBox % a ", " b
}
if(shortExecute){
	a:=false && b:=true
	MsgBox % a "," b	;0,
}
if(CaseSensitive){
	MsgBox % "Aa"="aA"	;true
}
if(objectEnum_Next){
;	see EverythingSearchEngine.ahk
	o:={_NewEnum:"Enumerator"}
	r:=""
	for k,v in o
		r.=k
	MsgBox % r
	Enumerator(){
		global state:=0
		return {Next:"Next"}
	}
	Next(ByRef k,ByRef v){
		global state
		state++
		k:=v:=state
		if(state<3)
			return true
	}
	;	Next(o,ByRef k,ByRef v)
	;		wont invoke
}

return

if(WScript_Shell_Exec_IsAdmin_ErrorLevel_Output){
	;	see https://www.cnblogs.com/RobertL/p/14818503.html
	shell := ComObjCreate("WScript.Shell")
	ExecThenOutput(command){
		global shell
		exec := shell.Exec(ComSpec " /V:ON /C " . command)
		FileAppend, % exec.StdOut.ReadAll() "`n",*
	}
	;~ ExecThenOutput("net session 2>&1")
	;	发生系统错误 5。拒绝访问。
	;~ ExecThenOutput("echo %errorlevel%")
	;	0
	;~ ExecThenOutput("net session 2>&1 && echo %errorlevel%")
	;	发生系统错误 5。拒绝访问。
	;~ ExecThenOutput("net session 2>&1 `; echo %errorlevel%")
	;	此命令的语法是:..
	;~ ExecThenOutput("net session 2>&1 || echo %errorlevel%")
	;	发生系统错误 5。拒绝访问。
	;	0
	;~ ExecThenOutput("chcp")
	;	活动代码页: 936
	;~ ExecThenOutput("net session 2>&1 | chcp")
	;	活动代码页: 936
	;~ ExecThenOutput("net session 2>&1 | echo %errorlevel%")
	;	0
	;~ ExecThenOutput("set x=0")
	;~ ExecThenOutput("set x=1 & echo %x% !x!")
	;	%x% 1
	ExecThenOutput("net session >nul 2>&1 & echo !errorlevel!")
	;	when not Administrator Mode 2
	;	when  Administrator Mode 0
	return
}
#IfWinActive ahk_exe EXCEL.EXE
NumpadDot::Tab
;~ #If WinActive("test.ahk ahk_exe SciTE.exe")
;~ F2::ExitApp
;~ F3::Reload
/* 
	MsgBox % previousFilePath:=RegExReplace("a\b\ab`na\b\aab`na\b\abb`na\b\ab\a`na\b\ab","m`n)(?<=[/\\])\Q" . "ab" . "\E$","c") ", " ErrorLevel 
 */
 #If
 F2::
	nl:="`n"
	Length:=Length?Length:0
	NeedleRegEx :="P)·?[^·]+?.{" Length "," Length "}$"
	FoundPos:=RegExMatch(Clipboard,NeedleRegEx,Length)
	ToolTip % FoundPos nl Length nl Clipboard nl NeedleRegEx nl SubStr(Clipboard,FoundPos,Length)
	return
 #If WScript
F2::
	shell := ComObjCreate("WScript.Shell")
	exec := shell.Exec(ComSpec " /V /C net session >nul 2>&1 & echo !errorlevel!")
	MsgBox % exec.StdOut.ReadAll()
	return
#If
F1::
	ControlGetFocus, OutputVar,A
	ToolTip % OutputVar ", " ErrorLevel
	return
#If false
F1::
	FileSelectFile, OutputVar , M3, , ,
	;	FileSelectFile, OutputVar , Options, RootDir\Filename, Title, Filter
	;	M3: 3=1+2
	;		1: File Must Exist
	;		2: Path Must Exist
	if not OutputVar
		MsgBox Cancel
	else if ErrorLevel
		MsgBox Error
	else
		MsgBox % OutputVar
	if 0{
		if not OutputVar{
			MsgBox, The user pressed cancel.
			return
		}
		Loop, parse, OutputVar, `n
		{
			if (A_Index = 1)
				MsgBox, The selected files are all contained in %A_LoopField%.
			else
			{
				MsgBox, 4, , The next file is %A_LoopField%.  Continue?
				IfMsgBox, No, break
			}
		}
	}
	return
F2::
	MsgBox % dataFromToClipboard()
	return
q:: ;desktop get paths of selected files (tested on Windows 7)
;MsgBox, % JEE_ExpGetSelDesktop()
MsgBox, % Clipboard := JEE_ExpGetSelDesktop("`r`n")
return

JEE_ExpGetSelDesktop(vSep="`n")
{
	oWindows := ComObjCreate("Shell.Application").Windows
	VarSetCapacity(hWnd, 4, 0)
	;SWC_DESKTOP := 0x8 ;VT_BYREF := 0x4000 ;VT_I4 := 0x3 ;SWFO_NEEDDISPATCH := 0x1
	oWin := oWindows.FindWindowSW(0, "", 8, ComObject(0x4003, &hWnd), 1)
	vCount := oWin.Document.SelectedItems.Count
	vOutput := ""
	VarSetCapacity(vOutput, (260+StrLen(vSep))*vCount*2)
	for oItem in oWin.Document.SelectedItems
		if !(SubStr(oItem.path, 1, 3) = "::{")
			vOutput .= oItem.path vSep
	oWindows := oWin := oItem := ""
	return SubStr(vOutput, 1, -StrLen(vSep))
}
;----
dataFromToClipboard(){
	;cant get path on external device like phone
	originalClipboard:=ClipboardAll
	Clipboard=
	ClipWait,0.5
	Send ^c
	ClipWait,0.5
	clipboard := clipboard	; Convert any copied files, HTML, or other formatted text to plain text.
	text:=Clipboard
	Clipboard:=originalClipboard
	return text
}

