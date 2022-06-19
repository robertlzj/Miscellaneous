ToolTip(text){
StopToolTip:
	ToolTip
	if text{
		ToolTip % text
		;~ ToolTip:=Func("ToolTip")
		SetTimer, StopToolTip,% -1*Max(StrLen(text)*100,1000)
	}
	return
}