
	;Menu, Menu_Test_SubMenu, Add, Item1 in SubMenu, Menu_Test_SubMenu_Handle
	;Menu, Menu_Test_SubMenu, Add, Item2 in SubMenu, Menu_Test_SubMenu_Handle
Menu_Test_SubMenu:=[Menu_CreateStruct("Item1 in SubMenu","Menu_Test_SubMenu_Handle")
	,Menu_CreateStruct("Item2 in SubMenu","Menu_Test_SubMenu_Handle")]

	;Menu_IdContent:=[{Name:"Item A",Pin:false,SubMenu:false,Handle:"Menu_Test_Handle"}
	;	,{Name:"Item B",Pin:true,SubMenu:false,Handle:"Menu_Test_Handle"}
	;	,{Name:"Item C",Pin:false,SubMenu:false,Handle:"Menu_Test_Handle"}
	;	,{Name:"Item D",Pin:false,SubMenu:false,Handle:"Menu_Test_Handle"}
	;	,{Name:"Item E",Pin:false,SubMenu:false,Handle:"Menu_Test_Handle"}
	;	,{Name:"Item F",Pin:false,SubMenu:false,Handle:"Menu_Test_Handle"}
	;	,{Name:"Item G",Pin:true,SubMenu:true,Handle:"Menu_Test_SubMenu"}
	;	,{Name:"Item H",Pin:false,SubMenu:true,Handle:"Menu_Test_SubMenu"}
	;	,{Name:"Item I",Pin:true,SubMenu:false,Handle:"Menu_Test_Handle"}]
Menu_IdContent:=[Menu_CreateStruct("Item A","Menu_Test_Handle")
	,Menu_CreateStruct("Item B",true,"Menu_Test_Handle")
	,Menu_CreateStruct("Item C","Menu_Test_Handle")
	,Menu_CreateStruct("Item D","Menu_Test_Handle")
	,Menu_CreateStruct("Item E","Menu_Test_Handle")
	,Menu_CreateStruct("Item F","Menu_Test_Handle")
	,Menu_CreateStruct("Item G",true,Menu_Test_SubMenu)
	,Menu_CreateStruct("Item H",Menu_Test_SubMenu)
	,Menu_CreateStruct("Item I",true,"Menu_Test_Handle")]

goto Menu_scope_handle_end	;{
	Menu_Test_SubMenu_Handle:
		goto MenuHandle
		;	PopupMenu.ahk
	Menu_Test_Handle:
		return
	Menu_CreateStruct(name,params*){
		if params.Count=1
			handle=params[1]
		else{
			if not params.Count=2{
				MsgBox  Params Error.
				Exit
			}
			pin:=params[1]
			handle:=params[2]
		}
		if not IsLabel(handle) or not IsFunc(handle) or not IsObject(hanlde){
			MsgBox Handle Error.
			Exit
		}
		return {Name:name,Pin:pin,Handle:handle}
	}
Menu_scope_handle_end: ;}