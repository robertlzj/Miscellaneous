#NoEnv
#SingleInstance,Force

SetTitleMatchMode, 2
Map:={}
/*{
		a:1,
		"a.b":2,
		c.d:3	;×
	}
*/
Content=
(
)
Loop, Parse, Content, `n, `r
{
	RegExMatch(A_LoopField,"O)(.*)`t(.*)",O)
	Map[O[1]]:=O[2]
}
return

#IfWinActive SciTE4AutoHotkey
~^c::
	ExitApp
F5::reload

#If
~^a::
$^c::
	Clipboard:=""
	Send ^c
	ClipWait,0
	if(ErrorLevel)
		Exit
	Original:=Clipboard
	Clipboard:=""
	New:=""
	Loop, Parse, Original, `n, `r
	{
		Current:=Map[A_LoopField]?Map[A_LoopField]:A_LoopField
		FileAppend, %A_LoopField%>%Current%`n, *
		New.=Current . "`r`n"
	}
	New:=Trim(New,"`r`n")
	Clipboard:=New
	Send ^v
	FileAppend,`n, *
	Exit