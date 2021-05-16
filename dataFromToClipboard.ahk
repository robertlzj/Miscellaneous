dataFromToClipboard(contentToPaste=""){
	;	cant get path on external device like phone
	originalClipboard:=ClipboardAll
	initialClipboard:=Clipboard
	Clipboard:=contentToPaste?contentToPaste:""
	if initialClipboard!=contentToPaste
		ClipWait,0.5
	if contentToPaste{
		Send ^v
		Sleep 200
	}else{
		Send ^c
		ClipWait,0.5
		clipboard := clipboard	; Convert any copied files, HTML, or other formatted text to plain text.
		text:=Clipboard
	}
	Clipboard:=originalClipboard
	return text
}