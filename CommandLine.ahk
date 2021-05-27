#SingleInstance,Force

goto end

;Autohotkey.chm \ Run[Wait] \ examples \ #2
RunWaitOne(command) {
    ; WshShell object: http://msdn.microsoft.com/en-us/library/aew9yb99?
    shell := ComObjCreate("WScript.Shell")
    ; Execute a single command via cmd.exe
    exec := shell.Exec(ComSpec " /C " command)
    ; Read and return the command's output
    return exec.StdOut.ReadAll()
}
IsAdmin_TestByWScriptCommand(){
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

    return not RunWaitOne("net session 2>&1")
}
IsAdmin_TestByCommandLine(){
    RunWait %ComSpec% /C net session >nul 2>&1
    return ErrorLevel=0
     ;   ERRORLEVEL:
    ;       0: Administrative permissions confirmed.
    ;       2: failed
}

;----debug/test----
#IfWinActive CommandLine.ahk ahk_class SciTEWindow ahk_exe SciTE.exe
F1::Reload
F2::ExitApp
F3::
	MsgBox % "Is Admin: `n`tGet from A_IsAdmin: " (A_IsAdmin?"true":"false")
	. "`n`tTest by command line from WScript: " (IsAdmin_TestByWScriptCommand()?"true":"false")
	. "`n`tTest by command line from Run: " (IsAdmin_TestByCommandLine()?"true":"false")
	;	result may not the same - A_IsAdmin=true, IsAdmin_TestByWScriptCommand()=false, IsAdmin_TestByCommandLine=true, when run under administrator.
    return
F4::
    IsAdmin_TestByCommandLine()
    return
#IfWinActive

end: