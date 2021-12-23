LastTime:=A_TickCount
DoubleClickInterval:=200
#Include SelectOrReadSelection.ahk
goto end20211223	;{
	#If WinActive("ahk_exe explorer.exe") and GetKeyState("CapsLock","P") and (A_TickCount-LastTime)<DoubleClickInterval ;{
	LButton::
		;~ ToolTip Interrupt Double Click Down
		;~ ToolTip % SelectOrReadSelection()
		return	;}
	#If WinActive("ahk_exe explorer.exe") and not GetKeyState("CapsLock","P") and (A_TickCount-LastTime)<DoubleClickInterval ;{
	~LButton::
		;~ ToolTip Normal Double Click Down
		return	;}
	#If WinActive("ahk_exe explorer.exe")	and (A_TickCount-LastTime)>=DoubleClickInterval	;{
	~LButton::
		;~ ToolTip Click Down
		LastTime:=A_TickCount
		return	;}
	/*use less, debug
		#If WinActive("ahk_exe explorer.exe")	;{
		~LButton Up::
			;~ ToolTip Click Release
			return	;}
		#If
		F1::ToolTip % "A_PriorHotkey: " A_PriorHotkey ", A_TimeSincePriorHotkey: " A_TimeSincePriorHotkey
	*/
	#If
end20211223:	;}
return