#SingleInstance, Force

Function_Name_wID_Map:={切换锁定:32927
,变量替换:32879
,标记动作对象:33117
,打成智能对象:33385	;操作\打成智能单元，上下文菜单\组合拆分\打成智能单元
,解开智能单元:33386	;操作\解开智能单元，上下文菜单\组合拆分\解开智能单元
,对象内编辑:33387	;上下文菜单\
,对象属性:32866	;上下文菜单\，对象\
,显示图层:33301	;工具栏\显示界面图层
,打成组:32797	;操作\兼容操作
,拆开组:32798	;操作\兼容操作
,对象命名:33056}	;上下文菜单\
HotKey_Function_Name_Map:={"!1":"切换锁定","!2":"变量替换","!3":"打成智能对象","!+3":"解开智能单元","!4":"显示图层","!5":"打成组","!+5":"拆开组"
,"!q":"标记动作对象","!w":"对象内编辑","!e":"对象属性","!r":"对象命名"}
Hotkey, IfWinActive, 开发系统 ahk_exe draw.exe
for Key,WM_COMMAND_wID in HotKey_Function_Name_Map{
	Hotkey, % Key, HotKey_Handle
}
History_Function_Name_List:={}
return

#IfWinActive 开发系统 ahk_exe draw.exe
Alt::
	if(A_PriorHotkey==A_ThisHotkey){
		Tip:="快捷键:`n"
		for Key,Value in History_Function_Name_List{
			Tip.="F" . Key . ":" . Value . "`n"
		}
		Tip.="`n"
		for Key,Value in HotKey_Function_Name_Map{
			Tip.=Key . ":" . Value . "`n"
		}
		ToolTip,% Tip
		SetTimer, Clear_Tooltip, -5000
	}
	return
F1::
F2::
F3::
HotKey_Handle:
	;~ WinGetActiveTitle, Title
	;~ MsgBox % Title
	;~ WinMenuSelectItem, % Title,, 文件, 打开
	;~ WinMenuSelectItem, % Title,, 1&, 2&
	Function_Name_From_Fix_Hotkey:=HotKey_Function_Name_Map[A_ThisHotkey]
	if(Function_Name_From_Fix_Hotkey){
		Function_Name:=Function_Name_From_Fix_Hotkey
		for Key,Value in History_Function_Name_List{
			if(Value==Function_Name){
				History_Function_Name_List.RemoveAt(Key)
				break
			}
		}
		History_Function_Name_List.InsertAt(1,Function_Name)
		History_Function_Name_List.RemoveAt(4)
	}else{
		Function_Name_From_History:=History_Function_Name_List[SubStr(A_ThisHotkey,2)]
		Function_Name:=Function_Name_From_History
	}
	wID:=Function_Name_wID_Map[Function_Name]
	PostMessage, 0x0111,% wID, 0,
	ToolTip,% Function_Name
		;~ . "wID:" . wID
	SetTimer, Clear_Tooltip, -1000
	;~ MsgBox % ErrorLevel
	return
Clear_Tooltip:
	ToolTip
	return
;~ #If false
F4::	;导出"变量管路"-"引用搜索"-"信息输出"（ListBox）。
	MouseGetPos,_,_,OutputVarWin, OutputVarControl, 2
	;~ MsgBox % OutputVarWin . "`n" . OutputVarControl
	;~ ControlGet, OutputVar, List ,,ListBox1, A
	ControlGet, OutputVar, List ,,, ahk_id  %OutputVarControl%
	if ErrorLevel
		return
	ToolTip, Retrieved`, stored in Clipboard
	SetTimer, Clear_Tooltip, -1000
	Clipboard:=OutputVar
	return
;历史记录
if false {	;临时任务
	Clipboard:=""
	Send ^c
	ClipWait,0
	if ErrorLevel
		return
	T:=StrReplace(Clipboard,"RealToStr","IntToStr")
	Clipboard:=StrReplace(T,",0)",")")
	Send ^v
	Sleep 300
	Send {Tab}{Enter}{ESC}
	return
}