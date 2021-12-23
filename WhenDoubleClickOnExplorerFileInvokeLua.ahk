LastTime:=A_TickCount
DoubleClickInterval:=200

#Include SelectOrReadSelection.ahk

IterfacePort:=80011
connect:=false
#Include lib\Socket.ahk
client := new SocketTCP()
SocketSend(content:=""){
	global connect
	try{
		if(content){
			if(not connect){
				;~ ToolTip, my Socke`nConnecting..
				client.Connect(["localhost", IterfacePort])
				;	or 127.0.0.0
				;	may throw exception "Connect Failed"
				;~ ToolTip, my Socke`nConnected
				connect:=true
			}
			client.SendText(content "`n")
			;	may throw exception "Send Failed"
			;~ ToolTip, my Socke`nSent
		}else{
			client.Disconnect()
			;	may throw exception "Disconnect Failed"
			;~ ToolTip, my Socke`nDisconnect
			connect:=false
		}
		return true	;success
	}catch e{
		connect:=false
		;~ ToolTip, my Socket`nConnect/Send/Disconnect Failed.
		return false
	}
}
if(test=false){
	SocketSend("test")
	Sleep 2000
	SocketSend()
}
OnExit:
	if(connect){
		try{
			client.Disconnect()
		}catch e{
			;~ ToolTip, my Socket`nDisconnect Failed.
		}
		connect:=false
	}
	return

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