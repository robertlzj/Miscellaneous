
Menu, Menu_Test_SubMenu, Add, Item1 in SubMenu, Menu_Test_SubMenu_Handle
Menu, Menu_Test_SubMenu, Add, Item2 in SubMenu, Menu_Test_SubMenu_Handle

Menu_IdContent:=[{Name:"Item A",Pin:false,SubMenu:false,Handle:"Menu_Test_Handle"}
	,{Name:"Item B",Pin:true,SubMenu:false,Handle:"Menu_Test_Handle"}
	,{Name:"Item C",Pin:false,SubMenu:false,Handle:"Menu_Test_Handle"}
	,{Name:"Item D",Pin:false,SubMenu:false,Handle:"Menu_Test_Handle"}
	,{Name:"Item E",Pin:false,SubMenu:false,Handle:"Menu_Test_Handle"}
	,{Name:"Item F",Pin:false,SubMenu:false,Handle:"Menu_Test_Handle"}
	,{Name:"Item G",Pin:true,SubMenu:true,Handle:"Menu_Test_SubMenu"}
	,{Name:"Item H",Pin:false,SubMenu:true,Handle:"Menu_Test_SubMenu"}
	,{Name:"Item I",Pin:true,SubMenu:false,Handle:"Menu_Test_Handle"}]

goto Menu_scope_handle_end
	Menu_Test_SubMenu_Handle:
		goto MenuHandle
	Menu_Test_Handle:
		return
Menu_scope_handle_end: