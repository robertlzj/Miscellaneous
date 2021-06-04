
Menu, Menu_Test_SubMenu, Add, Item1 in SubMenu, Menu_Test_SubMenu
Menu, Menu_Test_SubMenu, Add, Item2 in SubMenu, Menu_Test_SubMenu

Menu_IdContent:=[{Name:"Item A",pin:false,subMenu:false,handle:test_handle}
	,{Name:"Item B",pin:true,subMenu:false,handle:Menu_test_handle}
	,{Name:"Item C",pin:false,subMenu:false,handle:Menu_test_handle}
	,{Name:"Item D",pin:false,subMenu:false,handle:Menu_test_handle}
	,{Name:"Item E",pin:false,subMenu:false,handle:Menu_test_handle}
	,{Name:"Item F",pin:false,subMenu:false,handle:Menu_test_handle}
	,{Name:"Item G",pin:true,subMenu:true,handle:"Menu_Test_SubMenu"}
	,{Name:"Item H",pin:false,subMenu:true,handle:"Menu_Test_SubMenu"}
	,{Name:"Item I",pin:true,subMenu:false,handle:Menu_test_handle}
	]

goto Menu_scope_handle_end
	Menu_test_handle:
		MsgBox %A_ThisMenu% \ %A_ThisMenuItem% (%A_ThisMenuItemPos%)`nModifier State: %ModiferState%.
		return
		
Menu_scope_handle_end: