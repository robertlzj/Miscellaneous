LastTime:=A_TickCount
DoubleClickInterval:=200

#Include SelectOrReadSelection.ahk

#Include lib\Socket.ahk
client := new SocketTCP()
try{
	if(not connect){
		connect:=true
		ToolTip, my Socke`nConnecting..
		client.Connect(["localhost", 8000])
		;	or 127.0.0.0
	}
	tickCount:=A_TickCount
	ToolTip, my Socke`nSend %tickCount%
	client.SendText(tickCount (Mod(tickCount,2)==1 ? "`n" : ","))
}catch e{
	Sleep, 1000
	ToolTip, my Socket`nConnent/Send/Disconnect Failed`, try again
}
OnExit:
	client.Disconnect()

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