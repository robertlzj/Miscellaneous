;不可靠，还是Lua FFMpeg吧

#SingleInstance,Force
SetTitleMatchMode, 1
#IfWinActive ahk_exe SciTE.exe
F1::Reload
F2::ExitApp
#If
F1::
	OutputDebug, Begin
	;~ Loop, read, filelist.txt
	Loop, Parse, % Clipboard,`n,`r
	{
 		filepath:="D:\" . A_LoopField
		filename:=SubStr(A_LoopField,InStr(A_LoopField,"\")+1)
		if not filename
			return
		OutputDebug,% "filepath is: " filepath ", filename is: " filename "."
		command="C:\Program Files\DAUM\PotPlayer\PotPlayerMini64.exe" "%filepath%" /autoplay /current
		;	cant use "/seek=00:10:00.0"
		OutputDebug, Run: %command%.
		Run,% command,,OutputVarPID
		WinActivate ahk_pid %OutputVarPID%
		WinWaitActive % filename
		Send ^{Right}
		Sleep 2000
		OutputDebug, %filename% Loaded.`n
		CheckActive()
		Send ^e
		WinWait, 提示 ahk_class #32770,,1
		if not ErrorLevel{
			ToolTip, Capture failed
			TrayTip, Capture failed, %filename%, 1 ;画面无法截取
			return
		}
		ToolTip, Captured  %filename%
	}
	ToolTip, Capture Finished
	TrayTip, Capture Finished.,,5
return
F2::ExitApp
F3::Reload

CheckActive(){
	if not WinActive(){
		TrayTip, Capture Interrupt
		Exit
	}
}