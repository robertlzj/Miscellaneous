#SingleInstance,Force
waitTime:=300
return
Paste(content,errorMessage){
	Clipboard:=""
	Clipboard:=content
	ClipWait,0.5
	if(ErrorLevel){
		OutputDebug,% errorMessage
		gosub ProcessEnd
	}
	Send ^v
}
autoNext:
	OutputDebug,autoNext
	WinActivate ahk_id %targetHwnd%
	WinWaitActive ahk_id %targetHwnd%,,1
	if(ErrorLevel){
		OutputDebug,autoNext WinWaitActive failed.
		Exit
	}
	;~ Sleep 1000
	goto Process
^F12::
Process:
	WinGetTitle,activeTitle,A
	OutputDebug,Active Title=%activeTitle%
	orignClipboard:=ClipboardAll
	pressTime:=A_TickCount
	if WinActive("ahk_exe msedge.exe"){
		;~ "ahk_exe ApplicationFrameHost.exe" Edge
		;~ SetTimer,autoNext,-500
		Send ^d
		Sleep 300+waitTime
		Clipboard:=""
		Send ^c{Esc}
		ClipWait,0.8
		if(ErrorLevel){
			OutputDebug,Web Explorer title copy failed.
			title:=""
			goto ProcessEnd
		}else{
			title:=Clipboard
			OutputDebug, title=%title%
		}
		Clipboard:=""
		Sleep 200+waitTime
		Send ^l
		Sleep 500
		Send ^x
		ClipWait,1
		if(ErrorLevel){
			OutputDebug,Web Explorer address copy failed.
			address:=""
			goto ProcessEnd
		}else{
			address:=Clipboard
			OutputDebug, address=%address%
		}
		Sleep 100+waitTime
		Send {Esc}
		if(AutoNext){
			goto autoNext
		}
	}else if WinActive("ahk_exe ONENOTE.EXE") and title and address{
		targetHwnd:=WinActive("A")
		Send ^k
		WinWaitActive ahk_class NUIDialog,,0.5
		if(ErrorLevel){
			OutputDebug,OneNote link dialog open failed.
			goto ProcessEnd
		}
		Send !t
		Paste(title,"OneNote link title paste failed.")
		Send {Tab}
		Sleep 200+waitTime
		;----
		Paste(address,"OneNote link address paste failed.")
		Send {Enter}
	}else if WinActive("ahk_exe EXCEL.EXE") and title and address{
		targetHwnd:=WinActive("A")
		Send ^k
		WinWaitActive ahk_class ahk_class bosa_sdm_XL9,,1
		if(ErrorLevel){
			OutputDebug,Excel link dialog open failed.
			goto ProcessEnd
		}
		Paste(address,"EXCEL link address paste failed.")
		Sleep 200+waitTime
		Send !t
		Paste(title,"EXCEL link title paste failed.")
		Send {Enter}
	}
ProcessEnd:
	Clipboard:=orignClipboard
	Exit
^F12 Up::
	if WinActive("ahk_exe ApplicationFrameHost.exe"){
		if(A_TickCount-pressTime<400){
			OutputDebug, skip auto next
			;~ SetTimer,autoNext,Off
			AutoNext:=false
		}else{
			AutoNext:=true
		}
	}
	Exit