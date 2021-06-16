#SingleInstance,Force

;(Solved) How to hide cmd window? - AutoHotkey Community
;   https://www.autohotkey.com/boards/viewtopic.php?t=4075
    dhw := A_DetectHiddenWindows
    DetectHiddenWindows On
    Run "%ComSpec%" /k,, Hide, CommandLine_pid
    while !(hConsole := WinExist("ahk_pid" CommandLine_pid))
        Sleep 10
    DllCall("AttachConsole", "UInt", CommandLine_pid)
    DetectHiddenWindows %dhw%
    OnExit("CommandLine_OnExit")

; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99?
    shell := ComObjCreate("WScript.Shell")

goto end

;Autohotkey.chm \ Run[Wait] \ examples \ #2
RunWaitOne(command) {
    global shell
    ; Execute a single command via cmd.exe
    exec := shell.Exec(ComSpec " /C " command)
    ; Read and return the command's output
    return exec.StdOut.ReadAll()
}
IsAdmin_TestByWScriptCommand(){
    global shell
    ;   MsgBox % RunWaitOne("net session >nul 2>&1")
    ;   if ">nul", then nothing would be written to stdout (, neither errout)
    ;   if only ">nul", nothing would be written to stdout (, neither content of "发生系统错误 5。拒绝访问。")
    ;   if only "2>&1", content "发生系统错误 5。拒绝访问。" would be written to stdout.
    ;   "echo %ErrorLevel%" is always 0.
    ;
    ;   msgbox % ErrorLevel ", " A_LastError
    ;       0, 0 - even when not administered
    ;   MsgBox % RunWaitOne("echo %errorlevel%")
    ;       0 - even when not administered
	;~ return Trim(RunWaitOne("net session >nul 2>&1 | ECHO %ERRORLEVEL%"),"`r`n")
    ;   ERRORLEVEL:
    ;       0: Administrative permissions confirmed.
    ;       2: failed
    exec := shell.Exec(ComSpec " /V /C net session >nul 2>&1 & echo !errorlevel!" )
    ;   see https://www.cnblogs.com/RobertL/p/14818503.html
    errorlevel:=exec.StdOut.ReadAll()
    return Trim(errorlevel,"`r`n")=0
}
IsAdmin_TestByCommandLine(){
    RunWait %ComSpec% /C net session >nul 2>&1
    return ErrorLevel=0
     ;   ERRORLEVEL:
    ;       0: Administrative permissions confirmed.
    ;       2: failed
}
CommandLine_OnExit(){
    global CommandLine_pid
    DllCall("FreeConsole")
    Process Exist, %pid%
    if (ErrorLevel == CommandLine_pid)
        Process Close, %pid%
}

HandleSpaceInPath(path){
	global c
	if(not path~="^"".*""$" and InStr(path," "))
		path:=c . path . c
	return path
}

;----debug/test----
#IfWinActive CommandLine.ahk ahk_class SciTEWindow ahk_exe SciTE.exe
F3::Reload
F2::ExitApp
F4::
	MsgBox % "Is Admin: `n`tGet from A_IsAdmin: " (A_IsAdmin?"true":"false")
	. "`n`tTest by command line from WScript: " (IsAdmin_TestByWScriptCommand()?"true":"false")
	. "`n`tTest by command line from Run: " (IsAdmin_TestByCommandLine()?"true":"false")
	;	result may not the same - A_IsAdmin=true, IsAdmin_TestByWScriptCommand()=false, IsAdmin_TestByCommandLine=true, when run under administrator.
    return
F5::
    if(not A_IsAdmin){
        ;	see A_IsAdmin / Operating System and User Info / Built-in Variables / Variables and Expressions
        ;	see Run as Administrator / Run[Wait]
        Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
        ;	could not debug..
        ExitApp
    }
    return
#IfWinActive

end: