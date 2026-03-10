/*
    功能：
    - 双击CapsLock，切换为英文小写
    - 双击Shift，切换为中文
*/

#SingleInstance Force
#NoEnv
DetectHiddenWindows, On
StringCaseSense, On
Menu, Tray, Icon, IME_Aa.ico

Read_Mode_Default:="english"
Last_Trigger_TickCount:=A_TickCount
return

Read_Mode(){
    Format_Type:=GetKeyState("CapsLock", "T")
        ?"{:U}" ;大写
        :"{:s}" ;小写

    WinGet, hWnd, ID, A
    if (!hWnd)
        return Format(Format_Type,Read_Mode_Default)  ; 默认英文

    ; 获取IME窗口句柄
    DefaultIMEWnd := DllCall("imm32\ImmGetDefaultIMEWnd", "UInt", hWnd, "UInt")
    if (!DefaultIMEWnd)
        return Format(Format_Type,Read_Mode_Default)

    ; 发送消息获取转换模式 (IMC_GETCONVERSIONMODE = 0x001)
    ; WM_IME_CONTROL = 0x283
    SendMessage, 0x283, 0x001, 0,, ahk_id %DefaultIMEWnd%

    ; 返回值：0=英文模式，非0=中文模式
    return Format(Format_Type,(ErrorLevel == 0) ? "english" : "chinese")
}

Check_Mode(){
    global Last_Trigger_TickCount
    If(not (A_PriorHotkey = A_ThisHotkey and A_TimeSincePriorHotkey < 300))
        Exit
    Is_Triple:=(A_TickCount-Last_Trigger_TickCount) < 500
    Last_Trigger_TickCount:=A_TickCount
    if(Is_Triple){
        ;~ ToolTip "Triple"
        Exit
    }else{
        ;~ ToolTip "Double"
    }
    Sleep 100
    Mode:=Read_Mode()
    ;~ ToolTip % Mode
    return Mode
}

~$LShift Up::
    Mode_Start:=Check_Mode()
    switch Mode_Start
    {
        case "ENGLISH":
            SetCapsLockState, off
            Send {Shift}
        case "CHINESE":
            SetCapsLockState, off
        case "chinese":
        case "english":
            Send {Shift}
    }
    return

~$CapsLock Up::
F3::
    Mode_Start:=Check_Mode()
    switch Mode_Start
    {
        case "ENGLISH":
            SetCapsLockState, off
        case "CHINESE":
            SetCapsLockState, off
            Send {Shift}
        case "chinese":
            Send {Shift}
        case "english":
    }
    return
