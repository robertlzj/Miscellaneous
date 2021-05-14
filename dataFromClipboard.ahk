dataFromClipboard(replace){
	;cant get path on external device like phone
	originalClipboard:=ClipboardAll
	Clipboard=
	ClipWait,0.5
	Send ^c
	ClipWait,0.5
	clipboard := clipboard	; Convert any copied files, HTML, or other formatted text to plain text.
	text:=Clipboard
	if not replace
		Clipboard:=originalClipboard
	return text
}