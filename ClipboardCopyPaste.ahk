Clipboard(paste:=""){
	o:=ClipboardAll
	if(paste){
		Clipboard:=paste
		ClipWait,1
		Send ^v
		Sleep, 200
	}else{	;copy
		Clipboard:=""
		Send ^c
		ClipWait,1
		if not ErrorLevel
			c:=Clipboard
	}
	Clipboard:=o
	return c
}