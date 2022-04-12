;	https://github.com/G33kDude/Socket.ahk/blob/master/Examples/Server.ahk
#NoEnv
#SingleInstance, Force
SetBatchLines, -1
#Include Socket.ahk

port:=8080

Server := new SocketTCP()
Server.onRecv := Func("OnRecv")
Server.onAccept := Func("OnAccept")
Server.onDisconnect := Func("OnDisconnect")
Server.UserData:=123
Server.Bind(["0.0.0.0", port])
Server.Listen()
MsgBox, Serving on port %port%`nClose to ExitApp
Server.Disconnect()
ExitApp

OnAccept(Server){
	;OutputDebug, text
	;	or
	;FileAppend, text, *
	FileAppend, % A_Min ":" A_Sec " " &Server " OnAccept`n", *
	sock := Server.Accept()
	;~ FileAppend, % "Server.onRecv: " !!Server.onRecv ", Server.onDisconnect: " !!Server.onDisconnect "`n",*
	sock.onRecv:=Server.onRecv
	sock.onDisconnect:=Server.onDisconnect
	loop 0{
		receive:=sock.RecvLine()
		;FileAppend, receive: %receive%`n,*
		Response(sock,receive)
	}
}
OnDisconnect(master:=""){
	FileAppend, % A_Min ":" A_Sec " " &master " OnDisconnect`n", *
}
OnRecv(server){
	FileAppend, % A_Min ":" A_Sec " " &server " OnRecv`n", *
	FileAppend, % A_Min ":" A_Sec " Receive:" (receive:=server.RecvLine()) "`n", *
	Response(server,receive)
}
Response(sock,receive){
	RegExMatch(receive,"O)^(.+?)(\d*)$",received)
	request:=received[1],sleep:=received[2]
	FileAppend, % A_Min ":" A_Sec " " &sock " receive request: " request ", sleep: " sleep "`n", *
	if(request="quit"){
		FileAppend, % A_Min ":" A_Sec " " &sock "close.`n", *
		sock.Disconnect()
		return
	}
	sleep, sleep*1000
	FileAppend, % A_Min ":" A_Sec " " &sock " sent.`n", *
	sock.SendText(A_Min ":" A_Sec "`n")
}