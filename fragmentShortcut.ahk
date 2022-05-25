#NoEnv
#SingleInstance,Force
#Include dataFromToClipboard.ahk
#Include HotKey_WhenEditInSciTE.ahk
;~ #Include DelFileWithLink.ahk
;	DelFileWithLink_ExternalTrigger
#Include ClipboardCopyPaste.ahk
DelFileWithLink_ExternalTrigger:

Menu, Tray, Icon, fragmentShortcut-FS.ico
SetTitleMatchMode, 2
;	2: anywhere

goto fragmentShortcut_End

#IfWinActive ahk_class fltk ahk_exe gui_e30.exe	;EasyBuilder 威纶通 触摸屏 HMI 模拟仿真
~Esc::
	if(A_PriorHotkey="~Esc" and A_TimeSincePriorHotkey<300)
		WinClose, A
	return
	
#If  WinActive("ahk_exe zbstudio.exe") && ClassUnderMouse()~="wxWindowNR\d+"	;{
	;	wxWindowNRx: 每个标签是一个控件
/* 
	user.lua
		keymap[ID.RENAMEALLINSTANCES] = "Alt-R"
		keymap[ID.REPLACEALLSELECTIONS] = "Alt-Shift-R"
*/
~!R::	;{
	;~ ToolTip 1
	Send {Blind}{Shift down}
	SetTimer, Disable_ShiftDown, -800
	return	;}
~!+R::	;{
	;~ ToolTip 2
	SetTimer, Disable_ShiftDown, off
Disable_ShiftDown:	;{
	;~ ToolTip 3
	Send {Blind}{Shift up}
	return	;}
/* old method
	~!RButton::	;{
		Hotkey, If, WinActive("ahk_exe zbstudio.exe") && ClassUnderMouse()=="wxWindowNR8"
		Hotkey, R, SelectAllInstancesThenReplace
		SetTimer, Disable_SelectAllInstancesThenReplace, -800
		return	;}
	SelectAllInstancesThenReplace:
		Sleep 200
		Send {Up 6}{Enter}
	Disable_SelectAllInstancesThenReplace:
		Hotkey, R, SelectAllInstancesThenReplace, Off
		return
 */
#If	;}
	
#IfWinActive ahk_exe Typora.exe	;{
~^k Up::	;{Hyperlink
	orig_clipboard:=ClipboardAll
	Clipboard:=""
	;~ Send {Blind}+c	;Copy as Plain Text
	Send ^+c	;Copy as Plain Text
	ClipWait, 0.5
	;~ ToolTip % ErrorLevel
	Send {Right 3}{#}^v	;[..](#|)
	Sleep, 200
	Clipboard:=orig_clipboard
	return	;}
^+k::	;{insert
	selection:=Clipboard()
	SendInput <a name="%selection%"></a>{Left 4}
	return	;}
#If	;}

#If IsActiveWindow("\- 节点编辑器") && A_TimeSincePriorHotkey<1500
Tab::
#If IsActiveWindow("\- 节点编辑器")	;{
:C:tt::
	;C: Case sensitive
	;?: The hotstring will be triggered even when it is inside another word
	candidateList:=["type(){Left}","type'Text'{Left}+{Left 4}","type'TextView'{Left}+{Left 8}","type'Button'{Left}+{Left 6}"]
	candidateList[-1]:=6
	candidateList[-2]:=10-1
	candidateList[-3]:=StrLen("type'TextView'")-1
	candidateList[-4]:=12-1
	isBegin:=(A_TickCount-lastTrigerTickCount)>2000
	;	-'A_TimeSincePriorHotkey>2500 || A_TimeSincePriorHotkey=-1'
	lastTrigerTickCount:=A_TickCount
	;~ ToolTip % A_TimeSincePriorHotkey ", " index
	if not isBegin
		Send % "{Right}{BS " . candidateList[-index] . "}"
	index:=isBegin?1:(mod(index,candidateList.Length())+1)
	Send % candidateList[index]
	return
::fu::
	Send function(stack,event,super_event){Enter 2}end`,^[{Up}
	return
#If	;}

/*更新
	#If WinActive("ahk_exe msedge.exe") and not waiting_doubel_click 	;{
	~F1::	;{
		;始终会被游览器拦截..
		WinGetTitle, winTitle, A
		;~ ToolTip down
		if(winTitle~="\- 节点编辑器"){
			Send FA^a	;Fold All
			KeyWait, F1	;wait release
			;~ ToolTip KeyUp
			waiting_doubel_click:=true
			KeyWait, F1, DT1
			if not ErrorLevel	;not timeout
				;~ ToolTip double
				Send FA{Enter}
				;	不可仅仅`Send {Enter}`，始终会被游览器拦截
			;~ else
				;~ ToolTip single
			waiting_doubel_click:=false
		}
		return	;}
	#If	;}
*/
IsActiveWindow(title){
	if WinActive("ahk_exe msedge.exe"){
		WinGetTitle, winTitle, A
		return winTitle~=title
	}
}
IsSelect(){
	;节点精灵里总是有选择，默认为当前行
	local orig_clipboard:=ClipboardAll
	Clipboard:=""
	Send ^c
	ClipWait,0.5
	Clipboard:=orig_clipboard
	return !ErrorLevel
}
#If IsActiveWindow("\- 节点编辑器")	;{
~$F1::	;{
	Send FA^a
	if(A_PriorHotkey=A_ThisHotkey and A_TimeSincePriorHotkey<800){
		Send {Enter}
	}
	return	;}
F2::	;{
	if(A_PriorHotkey!=A_ThisHotkey or A_TimeSincePriorHotkey>1500){
		Send {F1}Du{Enter}
		Sleep, 500
		Send {Left}={{},{}},--{Left 5}	;Duplicate Selection
	}else if(A_PriorHotkey==A_ThisHotkey or A_TimeSincePriorHotkey<2500){
		Send {Del}{Enter}
	}
	return ;}
~^LButton::	;{
	if(A_PriorHotkey=A_ThisHotkey && A_TimeSincePriorHotkey<1000){
		ToolTip("Copy")
		Send ^c
	}
	return	;}
#If	;}
#If IsActiveWindow("节点精灵-节点查询工具")	;{
~LButton::	;{
	ToolTip
	MouseGetPos, mouse_down_x, mouse_down_y
	return	;}
~LButton up::	;{
	MouseGetPos, mouse_up_x, mouse_up_y
	if(A_PriorHotkey="~LButton" ;and A_TimeSincePriorHotkey>50
		&& (abs(mouse_up_x-mouse_down_x)>10 or abs(mouse_up_y-mouse_down_y)>10)){	;Select
		;~ ToolTip % abs(mouse_up_x-mouse_down_x) ", " abs(mouse_up_y-mouse_down_y)
		Send ^c
		ToolTip("Copy")
	}
	return	;}
#If	;}

#IfWinActive 指令:  ahk_exe HaiwellHappy.exe
$Enter::
	ControlSend 确定,{Enter},A
	return
Esc::
#IfWinActive 批量元件注释 ahk_exe HaiwellHappy.exe
Esc::
#IfWinActive 元件状态表 - 状态表1 ahk_exe HaiwellHappy.exe
Esc::
#IfWinActive 强制 ahk_exe HaiwellHappy.exe
Esc::
	Send !{F4}
	return

#IfWinActive ahk_exe TortoiseGitMerge.exe	;{
f1::
	Send ^o
~^o::
	WinWaitActive, TortoiseGitMerge, &Merging, 3
	if ErrorLevel{ ;timeout
		FileAppend, timeout, *
		return
	}
	FileAppend, find, *
	ControlSetText, Edit1, % A_ComputerName="ROBERTPAD"?"C:\Users\rober\Documents\Lua\temp.lua":"G:\My Documents\Lua\Lua\temp.lua"
	ControlSetText, Edit2, % A_ComputerName="ROBERTPAD"?"C:\Users\rober\Documents\Lua\temp2.lua":"G:\My Documents\Lua\Lua\"
	ControlFocus, Edit2
	ControlSend, Edit2, {End}
	return
#If	;}

#IfWinActive ahk_exe msedge.exe	;{
!`::	;{
	originalTitleMatchMode:=A_TitleMatchMode
	SetTitleMatchMode, 2
	if WinActive("- 节点编辑器")
		Send ^/
	else
		Send !`
	SetTitleMatchMode, % originalTitleMatchMode
	return	;}
#If	;}

#If
~#v::return
;~ a::ToolTip % A_PriorHotkey ", " A_TimeSincePriorHotkey	;debug
#If A_PriorHotkey="~#v" and A_TimeSincePriorHotkey<2000
;space:: ;select first
1::	;select second
2::
3::
4::
	;~ ToolTip % A_TickCount	;debug
	number:=A_ThisHotkey-1
	Send {Down  %number%}{Enter}
	return
#If

#IfWinActive ahk_exe msedge.exe
~^t::
	O_A_TitleMatchMode:=A_TitleMatchMode 
	SetTitleMatchMode, 1
	WinWaitActive, 新建标签页  ahk_exe msedge.exe
	SetTitleMatchMode, % O_A_TitleMatchMode
	;step not need (will active automatically)
	;~ Send {F4}	;active address bar
	;~ ToolTip % "A_CaretX: " A_CaretX
	;	no A_CaretX in msedge.exe\address bar
	SendEvent % "192" ;"{ASC " Asc(".") "}168{ASC " Asc(".") "}43{ASC " Asc(".") "}1{ASC " Asc(":") "}9090{ASC " Asc("/") "}dump"
	;	try auto complete
	Sleep 500
	Send {Enter}
	return
#If

#If WinActive("ahk_class WeChatMainWndForPC ahk_exe WeChat.exe")
~RButton::	;{prepare to select delete
	;~ ToolTip %  A_Cursor 
	;double right click:
	;	A_PriorHotkey="~RButton" and A_TimeSincePriorHotkey<400
	if(A_Cursor="Unknown"){
		orignMouseCoordMode:=A_CoordModeMouse
		CoordMode, Mouse, Screen
		MouseGetPos, orignX, orignY
		;~ ToolTip % x
		MouseMove, orignX>1329?-30:30, 219, 0, R
		waitForRestore:=A_TickCount
		CoordMode, Mouse, % orignMouseCoordMode
		Send {End}
	}
	return	;}
#If A_TickCount-waitForRestore<5000 and A_Cursor="Arrow" and WinActive("ahk_class WeChatMainWndForPC ahk_exe WeChat.exe")
~Esc::
	MouseMove, orignX>1329?+30:-30, -219, 0, R
	return

#If A_CaretX	;{..→:
~NumpadDot::
	if(A_PriorHotkey="~NumpadDot" and A_TimeSincePriorHotkey<200)
		Send % "{BS 2}{ASC " . Asc(":") . "}"
	return	;}
#If ;{ NumLock→Del
NumLock::
	;~ ToolTip % GetKeyState("NumLock","T")
	if(not NumLockDown  and A_CaretX)
		NumLockDown:=true
	return
#If A_CaretX and NumLockDown
NumLock up::
	p:=GetKeyState("NumLock","T")
	NumLockDown:=false
	if(A_PriorHotkey="NumLock")
		if (A_TimeSincePriorHotkey>200 or not p){
			SetNumLockState % !GetKeyState("NumLock", "T")
		}else if p{
			Send {BS}
	}
	;~ ToolTip % p GetKeyState("NumLock","T")
	return
#If	;}

#IfWinNotExist Active Window Info	;{
~#a::
	if false{	;failed
		WinWait,操作中心 ahk_class Windows.UI.Core.CoreWindow ahk_exe ShellExperienceHost.exe,,2
		if ErrorLevel	;always timeout
			return
	}else{
		WinWaitActive ,操作中心 ahk_class Windows.UI.Core.CoreWindow ahk_exe ShellExperienceHost.exe,,2
		if ErrorLevel
			return
	}
	originalMode:=A_CoordModeMouse
	CoordMode, Mouse, Screen
	MouseGetPos,mouse_x,mouse_y
	;~ MouseMove, 1380, 742
	MouseMove, A_ScreenWidth-50, A_ScreenHeight-80
	if false{	;failed
		KeyWait,Esc ,D L T3
		if not ErrorLevel	;often timeout
			MouseMove,mouse_x,mouse_y
	}else{
		activeWinA:=A_TickCount
	}
	CoordMode, Mouse, % originalMode
	originalMode:=""
	return
#If A_TickCount-activeWinA<2000
~Esc::
	originalMode:=A_CoordModeMouse
	CoordMode, Mouse, Screen
	MouseMove,mouse_x,mouse_y
	CoordMode, Mouse, % originalMode
	originalMode:=""
	return
;}

#If not MousePosition_PressAndUnRelease
CalcDistance(x1,y1,x2,y2){
	return Sqrt((x1-x2)**2+(y1-y2)**2)
}
~RControl::
	MousePosition_PressAndUnRelease:=true
restoreMousePostion:
	offset:=30
	originalMode:=A_CoordModeMouse
	CoordMode, Mouse, Screen
	MouseGetPos,MousePosition_current_x,MousePosition_current_y
	Sleep 150
	;	enough to wait to get new mouse positino set by tobii
	MouseGetPos,MousePosition_wait_x,MousePosition_wait_y
	if false{
		ToolTip % "last: " . MousePosition_last_x ","  MousePosition_last_y ",`n"
		 . "current: " . MousePosition_current_x ","  MousePosition_current_y ",`n"
		 . "fix: " . MousePosition_fix_x ","  MousePosition_fix_y ",`n"
		 . (MousePosition_last_x-MousePosition_current_x)**2 "," MousePosition_last_y-MousePosition_current_y ",`n"
		 . CalcDistance(MousePosition_last_x,MousePosition_last_y,MousePosition_current_x,MousePosition_current_y) ",`n"
		 . MousePosition_current_x ", " MousePosition_current_y "; " MousePosition_wait_x ", " MousePosition_wait_y
		;	cant use ^ as power
	}
	controledByTobii:=not (MousePosition_wait_x=719 and MousePosition_wait_y=450)
		and CalcDistance(MousePosition_current_x,MousePosition_current_y,MousePosition_wait_x,MousePosition_wait_y)>offset
	if(controledByTobii)
		return
	if(MousePosition_last_x){
		if(MousePosition_fix_x and CalcDistance(MousePosition_fix_x,MousePosition_fix_y,MousePosition_current_x,MousePosition_current_y)>offset){
			MousePosition_previous_x:=MousePosition_fix_x
			MousePosition_previous_y:=MousePosition_fix_y
		}else if(CalcDistance(MousePosition_last_x,MousePosition_last_y,MousePosition_current_x,MousePosition_current_y)>offset){
			MousePosition_previous_x:=MousePosition_last_x
			MousePosition_previous_y:=MousePosition_last_y
		}
		if(MousePosition_previous_x){
			MouseMove,MousePosition_previous_x,MousePosition_previous_y
			MousePosition_last_x:=MousePosition_previous_x
			MousePosition_last_y:=MousePosition_previous_y
			MousePosition_previous_x:=MousePosition_current_x
			MousePosition_previous_y:=MousePosition_current_y
		}else{
			MousePosition_last_x:=MousePosition_current_x
			MousePosition_last_y:=MousePosition_current_y
		}
	}else{
		MousePosition_last_x:=MousePosition_current_x
		MousePosition_last_y:=MousePosition_current_y
	}
	CoordMode, Mouse, % originalMode
	originalMode:=""
	return
#If MousePosition_PressAndUnRelease
~RControl up::
	MousePosition_PressAndUnRelease:=false
	if controledByTobii
		return
	if false
	ToolTip % A_TimeSincePriorHotkey "," A_PriorHotkey "`n"
		. "Fix: " . MousePosition_fix_x "," MousePosition_fix_y
	if(A_TimeSincePriorHotkey<400)
		return
	if(MousePosition_previous_x){
		gosub restoreMousePostion
	}
	if(A_TimeSincePriorHotkey>800){
		MousePosition_fix_x:=0
		MousePosition_fix_y:=0
	}else{
		SoundPlay,Click.mp3
		MousePosition_fix_x:=MousePosition_last_x
		MousePosition_fix_y:=MousePosition_last_y
	}
	return
	
;{一键发送文件到文件夹
#Include SelectOrReadSelection.ahk
#If WinActive("F:\备份\C-Users-RobertL-Pictures-Samsung Gallery Downloads\DCIM\Camera\")
F1::
	selections:=SelectOrReadSelection()
	folderPath:=""
	Loop, Parse, selections, `n
	{
		;(folderPath?filePath:folderPath):=A_LoopField
		if folderPath{
			filePath:=A_LoopField
			FileMove,% folderPath filePath, F:\备份\C-Users-RobertL-Pictures-Samsung Gallery Downloads\DCIM\Camera\已命名\
			if ErrorLevel
				MsgBox MoveFile Error.
		}else
			folderPath:=A_LoopField
	}
	return
#If
;}

;~ #If
;~ F3::
	;~ FileToClipboard("C:\Users\RobertL\Desktop\Photshop快速导出.png")
	;~ return
#IfWinActive ahk_exe Photoshop.exe
~F2::
	CurrentTime:=A_Now
	path=C:\Users\RobertL\Desktop\Photshop快速导出.png
	Loop{
		Sleep 200
		FileGetTime, ModificationTime, % path, M
		if(A_Now-CurrentTime>2){
			MsgBox Failed to get photoshop export file
			return
		}
	}Until ModificationTime-CurrentTime<5
	Clipboard:=""
	FileToClipboard(path)
	;~ Send !{Tab}
	;~ Sleep 200
	;~ Send ^v
	;~ FileDelete, % path
	;~ if(ErrorLevel!=0)
		;~ MsgBox Delete file Failed
	return

;https://autohotkey.com/board/topic/23162-how-to-copy-a-file-to-the-clipboard/
FileToClipboard1(PathToCopy){
    ; Expand to full path:
    Loop, %PathToCopy%, 1
        PathToCopy := A_LoopFileLongPath
     ; Allocate some movable memory to put on the clipboard.
    ; This will hold a DROPFILES struct, the string, and an (extra) null terminator
    ; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
    hPath := DllCall("GlobalAlloc","uint",0x42,"uint",StrLen(PathToCopy)+22)
    
    ; Lock the moveable memory, retrieving a pointer to it.
    pPath := DllCall("GlobalLock","uint",hPath)
    
    NumPut(20, pPath+0) ; DROPFILES.pFiles = offset of file list
    
    ; Copy the string into moveable memory.
    DllCall("lstrcpy","uint",pPath+20,"str",PathToCopy)
    
    ; Unlock the moveable memory.
    DllCall("GlobalUnlock","uint",hPath)
    
    DllCall("OpenClipboard","uint",0)
    ; Empty the clipboard, otherwise SetClipboardData may fail.
    DllCall("EmptyClipboard")
    ; Place the data on the clipboard. CF_HDROP=0xF
    DllCall("SetClipboardData","uint",0xF,"uint",hPath)
    DllCall("CloseClipboard")
}
;https://autohotkey.com/board/topic/23162-how-to-copy-a-file-to-the-clipboard/page-4#entry463462
FileToClipboard(PathToCopy,Method="copy")
{
   FileCount:=0
   PathLength:=0

   ; Count files and total string length
   Loop,Parse,PathToCopy,`n,`r
      {
      FileCount++
      PathLength+=StrLen(A_LoopField)
      }

   pid:=DllCall("GetCurrentProcessId","uint")
   hwnd:=WinExist("ahk_pid " . pid)
   ; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
   hPath := DllCall("GlobalAlloc","uint",0x42,"uint",20 + (PathLength + FileCount + 1) * 2,"UPtr")
   pPath := DllCall("GlobalLock","UPtr",hPath)
   NumPut(20,pPath+0),pPath += 16 ; DROPFILES.pFiles = offset of file list
   NumPut(1,pPath+0),pPath += 4 ; fWide = 0 -->ANSI,fWide = 1 -->Unicode
   Offset:=0
   Loop,Parse,PathToCopy,`n,`r ; Rows are delimited by linefeeds (`r`n).
      offset += StrPut(A_LoopField,pPath+offset,StrLen(A_LoopField)+1,"UTF-16") * 2

   DllCall("GlobalUnlock","UPtr",hPath)
   DllCall("OpenClipboard","UPtr",hwnd)
   DllCall("EmptyClipboard")
   DllCall("SetClipboardData","uint",0xF,"UPtr",hPath) ; 0xF = CF_HDROP

   ; Write Preferred DropEffect structure to clipboard to switch between copy/cut operations
   ; 0x42 = GMEM_MOVEABLE(0x2) | GMEM_ZEROINIT(0x40)
   mem := DllCall("GlobalAlloc","uint",0x42,"uint",4,"UPtr")
   str := DllCall("GlobalLock","UPtr",mem)

   if (Method="copy")
      DllCall("RtlFillMemory","UPtr",str,"uint",1,"UChar",0x05)
   else if (Method="cut")
      DllCall("RtlFillMemory","UPtr",str,"uint",1,"UChar",0x02)
   else
      {
      DllCall("CloseClipboard")
      return
      }

   DllCall("GlobalUnlock","UPtr",mem)

   cfFormat := DllCall("RegisterClipboardFormat","Str","Preferred DropEffect")
   DllCall("SetClipboardData","uint",cfFormat,"UPtr",mem)
   DllCall("CloseClipboard")
   return
   }
;https://autohotkey.com/board/topic/23162-how-to-copy-a-file-to-the-clipboard/#entry151037
ImageToClipboard(Filename)
{
    hbm := DllCall("LoadImage","uint",0,"str",Filename,"uint",0,"int",0,"int",0,"uint",0x10)
    if !hbm
        return
    DllCall("OpenClipboard","uint",0)
    DllCall("EmptyClipboard")
    ; Place the data on the clipboard. CF_BITMAP=0x2
    if ! DllCall("SetClipboardData","uint",0x2,"uint",hbm)
        DllCall("DeleteObject","uint",hbm)
    DllCall("CloseClipboard")
}

#If WinActive("ahk_exe zbstudio.exe ahk_class wxWindowNR") and ControlHasFocus()~="wxWindowNR" and ClassUnderMouse()~="wxWindowNR"
;	$!`::Send !``
;	cant
$!`::
	;~ ToolTip $!`
	ControlSend ,,!``,ahk_exe zbstudio.exe ahk_class wxWindowNR
	;	wxStyledTextCtrl
	;~ ToolTip % ErrorLevel
	return
#If

;{PowerToys
	#If not WinBarView and false
	~LWin::
		FileAppend % A_TickCount ": " A_ThisHotkey "`n", *
		;~ FileAppend % A_PriorHotkey ": " A_TimeSincePriorHotkey "`n", *
		Input, OutputVar, L1 M T0.2 V
		if(ErrorLevel="Timeout" and A_ThisHotkey!="$LWin up"){
		;~ if(A_PriorHotkey="~LWin"  and A_TimeSincePriorHotkey<600){
		;~ ;	repeate key after 500ms
		;	group 1
			FileAppend % A_TickCount ": On`n", *
			WinBarView:=true
			Send #+/ 
		}
		return
	;~ #If WinBarView
	;	group 1
	#If false
	$LWin up::
		FileAppend % A_TickCount ": " A_ThisHotkey "`n", *
		if WinBarView{
			WinBarView:=false
			Send {Blind}{Esc}{LWin up}
			;	need "{LWin up}", or Start Menu will be triggered
			;	maybe related with: #MenuMaskKey
		}
		return
	/*	old method
		#MaxThreadsPerHotkey, 2
		#If not WinBarView	;{PowerToys
		~LWin::
			FileAppend % A_TickCount ": " A_ThisHotkey "`n", *
			;~ FileAppend % A_PriorHotkey ": " A_TimeSincePriorHotkey "`n", *
			if(A_PriorHotkey="~LWin"  and A_TimeSincePriorHotkey<600){
				;	repeate key after 500ms
				FileAppend % A_TickCount ": On`n", *
				WinBarView:=true
				Send #+/ 
			}
			return
		#If WinBarView
		$LWin up::
			FileAppend % A_TickCount ": " A_ThisHotkey "`n", *
			if WinBarView{
				WinBarView:=false
				Send {Blind}{Esc}{LWin up}
				;	need "{LWin up}", or Start Menu will be triggered
				;	maybe related with: #MenuMaskKey
			}
			return	;}
	*/
;}

#IfWinActive inspection ahk_class AutoHotkeyGUI ahk_exe InternalAHK.exe
;	Object / Variable 
Esc::Send !{F4}
#IfWinActive [Debugging] ahk_class SciTEWindow ahk_exe SciTE.exe
~LButton::
	inspectVariableOn:=(A_PriorHotkey=A_ThisHotkey and A_TimeSincePriorHotkey<500)
	return
#If inspectVariableOn
~LButton up::
	if(A_TimeSincePriorHotkey>100 and A_PriorHotkey="~LButton"){
		Send +{F10}
		Sleep 200
		Send i	;Inspect variable...
	}
	return
#IfWinActive ahk_class SciTEWindow ahk_exe SciTE.exe
$F1::
	WinGet, OutputVar, ID ,AutoHotkey Help ahk_class HH Parent
	;	ahk_exe SciTE.exe ahk_exe hh.exe
	if OutputVar{
		;	WinActivate	;last found
		;	wont work
		dataFromToClipboard:=dataFromToClipboard()
		WinActivate	ahk_id %OutputVar%
		WinWaitActive	ahk_id %OutputVar%
		Send !2
		Sleep 200
		Send ^a
		dataFromToClipboard(dataFromToClipboard)
		Send {Enter}
	}else
		Send {F1}
	return

#IfWinActive ahk_class #32770, 否(&N)
;~ #IfWinActive ahk_class #32770 ahk_exe AutoHotkey, 否(&N)
;	not work
;~ #IfWinActive ahk_class #32770 ahk_exe AutoHotkey.exe, 否(&N)
;~ #IfWinActive ahk_class #32770 ahk_exe AutoHotkeyU32.exe, 否(&N)
Esc::!n

#IfWinActive, 删除 ahk_class #32770, 确实要	;{
;	"删除文件" / "删除多个项目"
;	"确实要把此文件放入回收站吗?" / "确实要永久性地删除此文件吗?" / "确实要将这 X 项移动到回收站吗?" / "确实要永久删除这 X 项吗?"
$Delete::Send {Enter}
#IfWinActive, 删除快捷方式 ahk_class #32770,你确定
;	"你确定要将此快捷方式移动到回收站吗?" / "你确定要永久删除此快捷方式吗?"
$Delete::Send {Enter}	;}

#IfWinActive 确认多个文件删除 ahk_class #32770 ahk_exe explorer.exe
Del::
	Send !y
	return
#IfWinActive	ahk_exe PotPlayerMini64.exe	;{
#IfWinActive 删除项目 ahk_class OperationStatusWindow
Del::
	Send !d
	return
#IfWinActive 播放列表 ahk_exe PotPlayerMini64.exe
Del::
#IfWinActive ahk_class PotPlayer64 ahk_exe PotPlayerMini64.exe
Del::
	PotPlayer_Del:
		Send +{Del}	;by default, del only apply to playlists
		WinWaitActive,删除 ahk_class #32770, 确实要, 1
		if not ErrorLevel
			;~ throw "WinWaitActive failed."
		;~ else
			gosub DelFileWithLink_ExternalTrigger
		return
	;	#IfWinActive 删除文件 ahk_class #32770 ahk_exe PotPlayerMini64.exe
	;		$Shift::
	;		$Delete::
	;			Send {Enter}
	;			return
	;		;	+Delete: in PotPlayer, delete file, prompt dialog whether to delete (to recycle bin)
	;Abstract.
	;	see "#IfWinActive, 删除 ahk_class #32770, 确实要“
	;Set by Logitech 游戏软件
	^i up::	;click
		;~ if(A_ThisHotkey=A_PriorHotkey and A_TimeSincePriorHotkey<300)
			;~ Send {Del}
		;~ else
			Send {PGDN}
		return
	^b up::	;long click
		Send {PGUP}
		return
	^u up::	;press
		; MsgBox % A_ThisHotkey	;test
		goto PotPlayer_Del
#IfWinActive fragmentShortcut.ahk ahk_class #32770 ahk_exe AutoHotkey.exe, delete all entrance?
	$Del::Send !y
	~Esc::
		;	WinWaitNotActive,,,0.5
		;	WinActivate 删除 ahk_class #32770, 确实要
		;	WinWaitActive,A,,0.5
		WinWaitActive, 删除 ahk_class #32770, 确实要, 0.5
		if ErrorLevel
			throw "WinWaitActive failed."
		Send {Esc}
		return
;}

#If	;QQ screen capture	;{
~^+a::	;{
	OutputDebug, QQ screen capture Lunch
	WinWaitActive ahk_class TXGuiFoundation,,0.5
	if ErrorLevel
		return
	OutputDebug, QQ screen capture Ready to search
	Capturing:=true
	;	WinGetPos , X, Y, Width, Height
	;	ImageSearch, OutputVarX, OutputVarY, X, Y, Width, Height, *2 QQ screen capture QQ截图截屏 文字识别.bmp
	;	if(not ErrorLevel){	;1 not found, 2 error
	;		MouseMove, OutputVarX, OutputVarY
	;	}
	return	;}
#If Capturing
~LButton up::	;{
	WinGetPos , X, Y, Width, Height, A
	Sleep 100
	OutputDebug, QQ screen capture X: %X%`, Y: %Y%`, Width: %Width%`, Height: %Height%
	Capturing:=false
	ImageSearch, OutputVarX, OutputVarY, 0, 0, Width, Height, *5 QQ screen capture QQ截图截屏 文字识别.bmp
	;	background is transparent
	;	Coordinates are relative to the active window
	if(not ErrorLevel){	;1 not found, 2 error
		MouseMove, % OutputVarX+5, % OutputVarY+5
		;	Coordinates are relative to the active window
		OutputDebug, Found
	}else
		OutputDebug, Not found (%ErrorLevel%)
	return	;}
;}
#IfWinActive AutoHotkey Help ahk_class HH Parent ;ahk_exe SciTE.exe	;{
;	ahk_exe hh.exe
!1::!c
!2::Send !n^a
!3::Send !s^a
;}
;~ !`::
#If WinActive("ahk_class XLMAIN ahk_exe EXCEL.EXE")	;{
	;~ and (GetKeyState("Control") or GetKeyState("Alt"))
	and ClassUnderMouse()="EXCEL61"
~^LButton::
~!LButton::
~^!LButton::
	OutputDebug, % A_ThisHotkey
	Enable:=true
	return	;}
#If Enable	;{
~LButton up::	;{
	Enable:=false
	OutputDebug, % A_ThisHotkey
	if(A_PriorHotkey~="^~[!^]{1,2}LButton$" and A_TimeSincePriorHotkey>500){
		;~ and dataFromToClipboard()!=""
		if A_PriorHotkey~="\^"
			Send ^b
		if A_PriorHotkey~="!"
			Send ^i
	}
	return	;}
;}
;Control Under Mouse Position:
ClassUnderMouse(){
	MouseGetPos , OutputVarX, OutputVarY, OutputVarWin, OutputVarControl
	return OutputVarControl
}
ControlHasFocus(){
	ControlGetFocus, OutputVar
	return OutputVar
}
#IfWinActive ahk_exe msedge.exe	;{
~^d::	;favorite
	WinWaitActive 编辑收藏夹
	Send ^c{Esc}
	return
~!d::	;{address bar
	;	ControlGetFocus, outputVar, A
	;	ToolTip % "ControlGetFocus: " outputVar ", Caret: " A_CaretX
	;	get nothing (in Edge).
	;	if(outputVar="Intermediate D3D Window1")
	;		Send ^c{Esc}
	if(A_PriorHotkey=A_ThisHotkey and A_TimeSincePriorHotkey<800)
		Send ^c
	return
	;}
;}
#IfWinActive ▶ ahk_exe msedge.exe	;{
RControl::
#IfWinActive 网易云音乐 ahk_exe msedge.exe
RControl::	;{
	if (A_PriorHotkey=A_ThisHotkey and A_TimeSincePriorHotkey<500)
		Send ^{Right}
	Send p
	return	;}
;}
#IfWinActive ahk_exe msedge.exe	;游览器
+RControl::
!r::
	Send ^+u	;read aloud
	return
#IfWinActive ahk_exe SLDWORKS.exe
$d::
	MouseGetPos,OutputVarX, OutputVarY, OutputVarWin, OutputVarControl
	;	The retrieved coordinates are relative to the active window
	if(OutputVarControl~="^AfxMDIFrame"){
		Send d
		Sleep 200
		MouseMove, OutputVarX+20, OutputVarY+20
		;	Coordinates are relative to the active window
	}else if(A_PriorHotkey=A_ThisHotkey and A_TimeSincePriorHotkey<1000)
		Click
	return
#If

ToolTip(text){
StopToolTip:
	ToolTip
	if text{
		ToolTip % text
		;~ ToolTip:=Func("ToolTip")
		SetTimer, StopToolTip, -1000
	}
	return
}

fragmentShortcut_End:
_:=_