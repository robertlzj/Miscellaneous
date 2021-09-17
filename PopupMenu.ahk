#SingleInstance Force
#Include HotKey_WhenEditInSciTE.ahk
Menu, Tray, Tip, #Z to Show menu`nactivate item with + to move Top after pin`, ^/Caps to Pin.
;	shortcut ^(number) wont work
;		^(word), !(number), !(word), Caps+(number), Caps+(word) works.

;TODO
;	handle sub menu for pin, move (shift) top.

CoordMode, Menu, Screen
CoordMode, Mouse, Screen
;	relative to the entire screen

HotkeyMap:=[1,2,3,4,5,"q","w","e","r","t","a","s","d","f","g"]
SubMenu_Index:=1
HotkeyIndex_Menu:={}
;	[menuId]=item count
method:=2
;	1: basic funtion test
;	2: customer menu

if(method=2){	;construct menu
	#Include *i Menu_IdContent.ahk
	#Include *i Menu_IndexId.ahk
	if not Menu_IndexId
		Menu_IndexId:=[]
	Count_Item_RootMenu:=Menu_IndexId.Length()
	if not Count_Item_RootMenu{
		Count_Item_RootMenu:=Menu_IdContent.Length()
		Loop % Count_Item_RootMenu
			Menu_IndexId[A_Index]:=A_Index
	}
	Count_Show_Item_Menu:=Min(Count_Item_RootMenu,15)
	MenuStruct_MenuName:={}
	ConstructMenu()
	goto Skip_MenuHandle
	MenuHandle:
		item:=Menu_IdContent[Menu_IndexId[A_ThisMenuItemPos]]
		ModiferState:=""
		if GetKeyState("Shift")
			ModiferState.="Shift"
		if GetKeyState("Ctrl")
			ModiferState.=" Ctrl"
		if GetKeyState("CapsLock")
			ModiferState.=" CapsLock"
		ToolTip %A_ThisMenu% \ %A_ThisMenuItem% (%A_ThisMenuItemPos%)`nModifier State: %ModiferState%.
		if(not IsLabel(item.Handle)){
			item_handle:=item.Handle
			MsgBox Error`nMenu Handle (%item_handle%) is not label.
			Exit
		}
		gosub % item.Handle
		newIndex:=""
		if(ModiferState~="Shift"){	;top after pin
			newIndex:=ShiftItemTopAfterPined(A_ThisMenuItemPos)
			if(newIndex and newIndex!=A_ThisMenuItemPos){
				Modified:=true
				;~ A_ThisMenuItemPos:=newIndex
				item:=Menu_IdContent[Menu_IndexId[newIndex]]
			}
		}
		if(ModiferState~="CapsLock" or ModiferState~="Ctrl"){	;toggle pin
			item.pin:=not item.pin
			Menu, % A_ThisMenu, ToggleCheck, %A_ThisMenuItem%
			Modified:=true
		}
		if Modified{
			Modified:=false
			Menu, % A_ThisMenu, DeleteAll
			ConstructMenu()
		}
		default:=newIndex?(newIndex "&"):A_ThisMenuItem
		Menu, % A_ThisMenu, Default, %default%
		ShowMenu()
		return
	;MenuTrigger
	
	Skip_MenuHandle:
}else
if(method=1){
	;{Create menu
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
	;}
	return  ; End of script's auto-execute section.

	MenuHandler2:
		MsgBox This will overwrite previous define.
		return
	MenuHandler:
		ModiferState:=GetKeyState("Shift")?"Holding Shift down"
			:(GetKeyState("Ctrl")?"Holding Ctrl down":"-")
		;	Ctrl is conflict with number shortcuts, Alt will close menu.
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
		;	StorePos()
		;?
		Restore()
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
}	;test

goto Skip_To_End
#z::	;{
	ShowMenu("MyMenu")
	return
;}
	
Restore(){
	;deprecate. keep for compatibility
	ShowMenu()
}
ShowMenu(myMenuName:=""){
	global HotkeyIndex_Menu
	HotkeyIndex_Menu:={}	;reset
	static MouseX, MouseY,MenuName
	if(myMenuName){
		MenuName:=myMenuName
		MouseGetPos MouseX, MouseY
	}
	Menu, % MenuName, Show,% MouseX,% MouseY
}
FindFirstUnpinItemIndex(from:=1){
	global Menu_IndexId,Menu_IdContent
	index:=from
	Loop{
		item:=Menu_IdContent[Menu_IndexId[index]]
		if not item or not item.Pin
			break
		index++
	}
	return index
}
ShiftItemTopAfterPined(indexToShift){
	;	apply to root menu, didn't support sub menu?
	global Menu_IndexId
	index_unpin:=0
	index_new:=""
	id_new_index:=Menu_IndexId[indexToShift]
	Menu_IndexId[indexToShift]:=""
	Loop{
		index_unpin++
		index_unpin:=FindFirstUnpinItemIndex(index_unpin)
		if not index_new
			index_new:=index_unpin
		id_origin_index_unpin:=Menu_IndexId[index_unpin]
		Menu_IndexId[index_unpin]:=id_new_index
		if not id_origin_index_unpin
			break
		id_new_index:=id_origin_index_unpin
	}
	return index_new
}
ConstructMenu(menuStruct:="",menuId:=""){
	global Count_Show_Item_Menu,Menu_IdContent,Menu_IndexId
	Loop % Count_Show_Item_Menu {
		item:=Menu_IdContent[Menu_IndexId[A_Index]]
		ConstructItem(item)
	}
}
ConstructItem(item,menuId:=""){
	global HotkeyMap,MenuStruct_MenuName,HotkeyIndex_Menu
	static freeMenuId=1
	hotkeyIndex:=HotkeyIndex_Menu[menuId]+1
	hotkeyIndex:=HotkeyIndex_Menu[menuId]:=hotkeyIndex?hotkeyIndex:1
	Hotkey:=hotkeyIndex<HotkeyMap.Count()?("&" hotkeyMap[hotkeyIndex] " "):""
	MenuItemName:=Hotkey item.Name
	type:=(IsLabel(item.Handle) or IsFunc(item.Handle))?"handle":"subMenu"
	;	label, handle -> handle
	;	object -> subMenu
	if(type="subMenu" and not MenuStruct_MenuName[item]){
		subMenuId:=MenuStruct_MenuName[item]:=menuId "_" freeMenuId++
		Loop,% item.Handle.Count(){
			ConstructItem(item.Handle[A_Index],subMenuId)
		}
	}
	;Menu, MyMenu, Add, % MenuItemName,% item.subMenu?(":" item.Handle):"MenuHandle",+Radio
	Menu, MyMenu%menuId%, Add, % MenuItemName,% type="handle"?"MenuHandle":(":MyMenu"  MenuStruct_MenuName[item]),+Radio
	;	Error:  Submenu must not contain its parent menu.
	;	item.Handle
	if item.Pin
		Menu, MyMenu%menuId%, Check, % MenuItemName
}
Skip_To_End:
_:=_