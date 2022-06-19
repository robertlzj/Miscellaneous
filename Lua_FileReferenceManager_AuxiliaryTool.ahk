#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Include HotKey_WhenEditInSciTE.ahk
global hwnd_OperandPath
global hwnd_FileReferenceManager

#If WinActive("ahk_class CabinetWClass ahk_exe explorer.exe") && check_ControlUnderMouse() && check_FielReferenceManager_active()	;{
	~LButton Up::	;{
		if(Selection:=SelectOrReadSelection()){
			OperandPath:=StrSplit(Selection,"`n")[2]
			if not Method_1
				ControlSetText,,% OperandPath, ahk_id %hwnd_OperandPath%
			;	won't trigger action in lua, if MULTILINE won't invoke valuechanged_cb too
			if ErrorLevel{
				hwnd_FileReferenceManager:=hwnd_OperandPath:=""
			}else{
				if Method_1{
					ControlSend,, ^a, ahk_id %hwnd_OperandPath%,
					;	won't trigger 'action' in lua in any case, won't trigger 'valuechanged_cb' if MULTILINE.
					Control, EditPaste,% OperandPath,, ahk_id %hwnd_OperandPath%
					;	will trigger 'valuechanged_cb' in lua (even when MULTILINE)
				}else{
					;comments see above
				ControlSend,, {End}, ahk_id %hwnd_OperandPath%,
				Control, EditPaste,% A_Space,, ahk_id %hwnd_OperandPath%
				ControlSend,, {Left}{Del}, ahk_id %hwnd_OperandPath%,
				;	{Backspace} won't be send
				}
				ToolTip("OperandPath:" OperandPath "`nSet success")
			}
		}
	return ;}
#If	;}

check_FielReferenceManager_active(){
	if(not hwnd_FileReferenceManager)
		update_FileReferenceManager_hwnd()
	if(hwnd_FileReferenceManager){	
		WinGet, ExStyle, ExStyle, ahk_id %hwnd_FileReferenceManager% 
		if(not ExStyle){
			hwnd_FileReferenceManager:=hwnd_FileReferenceManager:=""
		}else
			active:=ExStyle & 0x8  ; 0x8 is WS_EX_TOPMOST.
		;~ ToolTip % "FielReferenceManager " (active?"active":"in-active")
		return active
	}
}
update_FileReferenceManager_hwnd(){
	hwnd_FileReferenceManager:=WinExist("FileReferenceManager.lua ahk_class IupDialog ahk_exe lua53.exe")
	ControlGet, hwnd_OperandPath, Hwnd,, Edit2, ahk_id %hwnd_FileReferenceManager%
	ToolTip("hwnd_FileReferenceManager" (hwnd_FileReferenceManager?"":" not") " found"
		. "hwnd_OperandPath" (hwnd_OperandPath?"":" not") " found")
}
check_ControlUnderMouse(){
	MouseGetPos , OutputVarX, OutputVarY, OutputVarWin, OutputVarControl
	return OutputVarControl~="DirectUIHWND3" ;|| OutputVarControl~="SysTreeView321"
}
#Include SelectOrReadSelection.ahk
#Include ToolTip.ahk