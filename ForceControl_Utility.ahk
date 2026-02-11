#SingleInstance, Force
;{	开发系统
	Function_Name_wID_Map_开发系统:={切换锁定:32927
	,变量替换:32879
	,标记动作对象:33117
	,编译:32818	;开发系统\工具栏
	,关闭:57602	;文件\
	;,编译:32776	;脚本编辑器 ahk_class #32770
	,运行:32842	;开发系统\工具栏
	,打成智能对象:33385	;操作\打成智能单元，上下文菜单\组合拆分\打成智能单元
	,解开智能单元:33386	;操作\解开智能单元，上下文菜单\组合拆分\解开智能单元
	,对象内编辑:33387	;上下文菜单\
	,对象属性:32866	;上下文菜单\，对象\
	,显示图层:33301	;工具栏\显示界面图层
	,打成组:32797	;操作\兼容操作
	,拆开组:32798	;操作\兼容操作
	,设置对象图层:33300
	,文本替换:32866
	,定义方法属性:33413
	,对象命名:33056}	;上下文菜单\
	HotKey_Function_Name_Map_开发系统:={"!1":"切换锁定","!2":"变量替换","!3":"打成智能对象","!+3":"解开智能单元","!4":"显示图层","!5":"打成组","!+5":"拆开组"
	,"!q":"标记动作对象","!w":"对象内编辑","!e":"对象属性","!r":"对象命名","!f":"关闭"
	,"!a":"编译","!s":"运行","!d":"设置对象图层","!f":"文本替换","!g":"定义方法属性"}
	Hotkey, IfWinActive, 开发系统 ahk_exe draw.exe
	for Key,WM_COMMAND_wID in HotKey_Function_Name_Map_开发系统{
		Hotkey, % Key, HotKey_Handle
	}
;}
;{	DbManager
	Function_Name_wID_Map_DbManager:={导入:32836
		,导出:7297,保存:7249,退出:7242}
	HotKey_Function_Name_Map_DbManager:={"!1":"导入"
		,"!2":"导出"
		,"!3":"保存"
		,"!4":"退出"}
	Hotkey, IfWinActive, DbManager ahk_class #32770 ahk_exe draw.exe
	for Key,WM_COMMAND_wID in HotKey_Function_Name_Map_DbManager{
		Hotkey, % Key, HotKey_Handle
	}
;}
;{	脚本编辑器
	Function_Name_wID_Map_脚本编辑器:={保存:32771	;脚本编辑器 ahk_class #32770
	,变量选择:32781
	,关闭:2
	,缩进:32784
	,取消缩进:32884
	,注释:32779
	,取消注释:32787
	,查看帮助:32791
	,编译:32776}
	HotKey_Function_Name_Map_脚本编辑器:={"!d":"变量选择"
	,"!a":"编译","!s":"保存","!f":"关闭"
	,"!1":"缩进","!2":"取消缩进","!3":"注释","!4":"取消注释","!5":"查看帮助"}
	Hotkey, IfWinActive, 脚本编辑器 ahk_exe draw.exe
	for Key,WM_COMMAND_wID in HotKey_Function_Name_Map_脚本编辑器{
		Hotkey, % Key, HotKey_Handle
	}
;}
History_Function_Name_List:={}
;-----
;~ SetTimer,Wait_Set_Font,1000
SetTimer,Wait_Backup,1000
SetTimer,Wait_Export,1000
SetTimer,Wait_Import,1000
SetTimer,Wait_Rename,1000
SetTimer,Wait_Replace,1000
;~ SetTimer,Wait_Template_Update,1000
;~ SetTimer,Wait_Customer_Property,1000
;~ SetTimer,Wait_Property_Config,1000
;~ SetTimer,Wait_Method_Config,1000
return

Get_Name(){
	WinGetTitle, WinTitle
	RegExMatch(WinTitle,"O)^(开发系统|脚本编辑器|DbManager)",OutputVar)
	WinTitle:=OutputVar[1]
	;~ MsgBox % WinTitle
	return WinTitle
}

/*
	#If false
	!s::	;与`Hotkey`冲突（此处覆盖），虽然此热键受限于条件不会触发
		WinWaitActive, Draw ahk_class #32770 ahk_exe draw.exe, 文档已更改, 0.5
		if !ErrorLevel{
			ToolTip "自动保存" . %ErrorLevel%
			ControlClick, Button1
		}
		ToolTip
		return
*/

#IfWinActive ahk_exe draw.exe
Alt::
	WinTitle:=Get_Name()
	if(A_PriorHotkey==A_ThisHotkey AND WinTitle){
		Tip:="快捷键:`n"
		for Key,Value in History_Function_Name_List{
			Tip.="F" . Key . ":" . Value . "`n"
		}
		Tip.="`n"
		for Key,Value in HotKey_Function_Name_Map_%WinTitle%{
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
	WinTitle:=Get_Name()
	Function_Name_From_Fix_Hotkey:=HotKey_Function_Name_Map_%WinTitle%[A_ThisHotkey]
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
	wID:=Function_Name_wID_Map_%WinTitle%[Function_Name]
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
Wait_Backup(){
	WinWaitActive,项目备份 ahk_class #32770 ahk_exe Forcecontrol.exe,,0
	if(!ErrorLevel){
		ControlSetText, Edit1, D:\文档\项目\南通 KM2\程序\上位-力控\存档
		;ControlSetText, Edit1, D:\文档\项目\拓普思+固安-航天动力+液流水击\程序\存档
		ControlSetText, Edit2, 上位-力控+%A_YYYY%%A_MM%%A_DD%-%A_Hour%%A_Min%.PCZ
		WinWaitNotActive
	}
}
Wait_Export(){
	WinWaitActive,导出 ahk_class #32770 ahk_exe draw.exe,,0
	;~ ToolTip "Wait_Export" . %ErrorLevel%
	if(!ErrorLevel){
		ControlSetText, Edit1, D:\文档\项目\南通 KM2\程序\上位-力控\点表
		;~ ControlSetText, Edit1, D:\文档\项目\热防护地面增压输送供应系统+供气供水\程序\点表
		ControlSetText, Edit2, %A_YYYY%%A_MM%%A_DD%-%A_Hour%%A_Min%
		;~ Control, Check,,Button4	;文本方式
		WinWaitClose
		;~ ToolTip
	}
}
Wait_Import(){
	WinWaitActive,导入 ahk_class #32770 ahk_exe draw.exe,,0
	;~ ToolTip "Wait_Import" . %ErrorLevel%
	if(!ErrorLevel){
		Control, Check,,Button1
		SetTimer,Wait_Import_Config,-500
		WinWaitClose
		;~ ToolTip
	}
}
Wait_Import_Config(){
	;~ WinWaitActive,请选择操作 ahk_class #32770 ahk_exe draw.exe,,0
	;~ ToolTip "Wait_Import" . %ErrorLevel%
	if(!ErrorLevel){
		Control, Check,,Button2
		Control, Check,,Button6
		WinWaitClose
		;~ ToolTip
	}
}
Wait_Set_Font(){
	WinWaitActive,字体 ahk_class #32770 ahk_exe draw.exe,,0
	;~ ToolTip "Wait_Import" . %ErrorLevel%
	if(!ErrorLevel){
		ControlSetText, Edit1, Consola	;s
		Send {Down}
		ControlSetText, Edit2, 常规
		ControlSetText, Edit3, 四号
		WinWaitClose
		;~ ToolTip
	}
}
Wait_Rename(){
	WinWaitActive,对象名称 ahk_class #32770 ahk_exe draw.exe,,0
	;~ ToolTip "Wait_Import" . %ErrorLevel%
	if(!ErrorLevel){
		Send +{A_Tab}
		ControlGetText, Type, Edit1
		Type:=RegExReplace(Type,"\d*$","")
		;~ ControlSetText, Edit1, %Type%
		ControlSetText, Edit1,% Type . "_" RegExReplace(Clipboard,"\.","_")
		ControlFocus, Edit1
		Type_Length:=StrLen(Type)
		Send {Home}+{Right %Type_Length%}
		WinWaitClose
		;~ ToolTip
	}
}
Wait_Replace(){
	WinWaitActive,改变对象属性 ahk_class #32770 ahk_exe draw.exe,,0
	;~ ToolTip "Wait_Replace" . %ErrorLevel%
	if(!ErrorLevel){
		;~ Control, TabRight
		;	not work
		SendMessage, 0x1330, 1,, SysTabControl321, 改变对象属性
		;--
		WinGet, ControlList, ControlList
		Loop, Parse, ControlList, `n
		{
			ControlGetText, Text,% A_LoopField
			if(Text=="对象名称-占位"){
				ControlSetText,%A_LoopField%,%Clipboard%
				ControlFocus,%A_LoopField%
				break
			}
		}
		if(false){	;总是返回 label 控件
			;~ ControlFocus, 对象名称-占位
			;	not work
			;~ ControlFocus, Edit2
			ControlGet, Hwnd, Hwnd,, 对象名称-占位
			ToolTip Hwnd=%Hwnd%
			;~ ControlFocus,,ahk_id %Hwnd%
			ControlSetText,, %Clipboard%, ahk_id %Hwnd%
		}
		;~ ControlSetText, 对象名称-占位, %Clipboard%
		WinWaitClose
		;~ ToolTip
	}
}
Wait_Template_Update(){
	WinWaitActive,更新对象模板 ahk_class #32770 ahk_exe draw.exe,,0
	;~ ToolTip "Wait_Template_Update" . %ErrorLevel%
	if(!ErrorLevel){
		Control, Uncheck,, Button1
		Control, Uncheck,, Button2
		Control, Uncheck,, Button3
		Control, Uncheck,, Button4
		WinWaitClose
		;~ ToolTip
	}
}
Wait_Customer_Property(){
	WinWaitActive,自定义属性 ahk_class #32770 ahk_exe DRAW.EXE,,0
	;~ ToolTip "Wait_Customer_Property" . %ErrorLevel%
	if(!ErrorLevel){
		ControlGet, Enabled, Enabled,,Edit1
		IF Enabled
			ControlSetText, Edit1, 值
		ControlSetText, Edit3, 0
		Control, Choose, 1, ComboBox2
		ControlFocus, Edit4
		WinWaitClose
		;~ ToolTip
	}
}
Wait_Property_Config(){
	WinWaitActive,变量属性设置 ahk_class #32770 ahk_exe DRAW.EXE,,0
	;~ ToolTip "Wait_Property_Config" . %ErrorLevel%
	if(!ErrorLevel){
		ControlFocus, Button4
		WinWaitClose
		;~ ToolTip
	}
}
Wait_Method_Config(){
	WinWaitActive,修改对象自定义方法... ahk_class #32770 ahk_exe DRAW.EXE,,0
	;~ ToolTip "Wait_Method_Config" . %ErrorLevel%
	if(!ErrorLevel){
		ControlFocus, Button1
		WinWaitClose
		;~ ToolTip
	}
}
#IfWinActive 进程管理器 ahk_class #32770 ahk_exe Forcecontrol.exe
!s::
	PostMessage, 0x0111, 10031, 0,	;停止进程
	WinWait 力控进程管理器 ahk_class #32770 ahk_exe Forcecontrol.exe
	;~ MsgBox "OK"
	Send %A_Space%
	return
#IfWinActive 修改自定义函数...ahk_class #32770 ahk_exe draw.exe
Esc::WinClose

#IfWinActive 脚本编辑器 ahk_exe draw.exe
F4::
	ControlGet, OutputVar, CurrentLine
	MsgBox CurrentLine=%OutputVar%
#IfWinActive 用户自定义属性及方法 ahk_class #32770 ahk_exe draw.exe
!1::
	ControlClick Button1
	return
!2::
	ControlClick Button2
	return
!3::
	ControlClick Button3
	return

#IfWinActive 插入Activex控件 ahk_class #32770 ahk_exe draw.exe
#If
F4::	;导出"变量管路"-"引用搜索"-"信息输出"、"符合组件"-"插入Activex控件"（ListBox）。
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
#IfWinActive DbManager ahk_class #32770 ahk_exe draw.exe
F5::
	ToolTip DbManager

#IfWinActive 显示图层 ahk_class #32770 ahk_exe draw.exe
1::
2::
3::
4::
5::
6::
	ControlClick, Button%A_ThisHotkey%
	return
