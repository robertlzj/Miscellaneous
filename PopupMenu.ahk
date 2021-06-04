#SingleInstance
CoordMode, Menu, Screen
CoordMode, Mouse, Screen
;	relative to the entire screen

;{
	#Include *i Menu_IdContent.ahk
	#Include *i Menu_IndexId.ahk
	MemberList:=[ ;index-id
	]
;}

; Create the popup menu by adding some items to it.
Menu, MyMenu, Add, &1 Item1, MenuHandler
Menu, MyMenu, Add, &1 Item1, MenuHandler2
Menu, MyMenu, Add,&2 Item2, MenuHandler
Menu, MyMenu, Add  ; Add a separator line.

; Create another menu destined to become a submenu of the above menu.
Menu, Submenu1, Add, &1 Item1, MenuHandler
Menu, Submenu1, Add, &2 Item2, MenuHandler

; Create a submenu in the first menu (a right-arrow indicator). When the user selects it, the second menu is displayed.
Menu, MyMenu, Add, &3 My Submenu, :Submenu1
;	Menu, MyMenu, Add, &3 My Submenu, Submenu1
;	becomes item (not sub menu) (sub menu won't trigger label)

Menu, MyMenu, Add  ; Add a separator line below the submenu.
Menu, MyMenu, Add, &4 Item3, MenuHandler  ; Add another menu item beneath the submenu.

;	Original is "Tray"
Menu, MyMenu, Add ; separator
Menu, MyMenu, Add, TestToggle&Check default, TestToggle&Check, +Break
Menu, MyMenu, Add, TestToggle&Check Radio, TestToggle&Check, +Radio
Menu, MyMenu, Add, TestToggleEnable
Menu, MyMenu, Add, TestDefault,,+BarBreak
Menu, MyMenu, Add, TestStandard
Menu, MyMenu, Default, TestStandard
;	Can contain one with default style at most 
Menu, MyMenu, Add, TestDelete
Menu, MyMenu, Add, TestDeleteAll
Menu, MyMenu, Add, TestRename
Menu, MyMenu, Add, MenuHandler

return  ; End of script's auto-execute section.

MenuHandler2:
	MsgBox This will overwrite previous define.
	return
MenuHandler:
	ModiferState:=GetKeyState("Shift")?"Holding Shift down"
		:(GetKeyState("Ctrl")?"Holding Ctrl down":"-")
	;	Ctrl is conflict with shortcuts, Alt will close menu.
	MsgBox %A_ThisMenu% \ %A_ThisMenuItem% (%A_ThisMenuItemPos%)`nModifier State: %ModiferState%.
	Restore()
	return
Submenu1:
	MsgBox Won't trigger
	return

TestToggle&Check:
	Menu, MyMenu, ToggleCheck, %A_ThisMenuItem%
	Menu, MyMenu, Enable, TestToggleEnable ; Also enables the next test since it can't undo the disabling of itself.
	Menu, MyMenu, Add, TestDelete ; Similar to above.
	Restore()
	return

TestToggleEnable:
	Menu, MyMenu, ToggleEnable, TestToggleEnable
	Restore()
	return

TestDefault:
	if (Default = "TestDefault")
	{
		Menu, MyMenu, NoDefault
		Default := ""
	}
	else
	{
		Menu, MyMenu, Default, TestDefault
		Default := "TestDefault"
	}
	Restore()
	return

TestStandard:
	if (Standard != false)
	{
		Menu, MyMenu, NoStandard
		Standard := false
	}
	else
	{
		Menu, MyMenu, Standard
		Standard := true
	}
	Restore()
	return

TestDelete:
	Menu, MyMenu, Delete, TestDelete
	Restore()
	return

TestDeleteAll:
	StorePos()
	Menu, MyMenu, DeleteAll
	return

TestRename:
	if (NewName != "renamed")
	{
		OldName := "TestRename"
		NewName := "renamed"
	}
	else
	{
		OldName := "renamed"
		NewName := "TestRename"
	}
	Menu, MyMenu, Rename, %OldName%, %NewName%
	Restore()
	return

GuiContextMenu:	;Wont trigger
	ToolTip A_GuiControl: %A_GuiControl%`, A_GuiX: %A_GuiX%`, A_GuiY: %A_GuiY%`, A_GuiEvent: %A_GuiEvent%.
	return

#z::
	StorePos()
	Menu, MyMenu, Show  ; i.e. press the Win-Z hotkey to show the menu.
	;	Menu, Submenu1, Show  ; i.e. press the Win-Z hotkey to show the menu.
	;	;	will show when previous closed
	return
	
StorePos(){
	global
	MouseGetPos MouseX, MouseY
}
Restore(){
	global
	Menu, MyMenu, Show,% MouseX,% MouseY
}

#If WinActive("PopupMenu.ahk ahk_exe SciTE.exe")
F1::ExitApp
F2::Reload