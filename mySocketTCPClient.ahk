#NoEnv
#SingleInstance,Force
#Include lib\Socket.ahk
client := new SocketTCP()
return
F1::
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
		ToolTip, my Socket`nConnent/Send/Disconnect Failed
	}
	return
F2::
	if(connect){
		connect:=false
		ToolTip my Socket`nConnet Close
OnExit:
		client.Disconnect()
	}else
		ToolTip,
	return
#IfWinActive ahk_exe SciTE.exe
F1::
	Send {F5}
	return
F2::ExitApp