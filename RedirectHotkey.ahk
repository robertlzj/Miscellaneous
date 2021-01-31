#SingleInstance,Force
#IfWinActive ahk_exe zbstudio.exe
$+^F10::+^F10
	;~ ControlSend ,,+^{F10},A
	;~ Send +^{F10}
#If