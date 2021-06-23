#SingleInstance, Force
#NoEnv
#Include HotKey_WhenEditInSciTE.ahk
;	default F2 to reload then exit app
;for device path, can't use "Loop, Files", "FileExist"(, etc?)
;distinguish from item.Name and folder.Title and item.Path
;	see: https://docs.microsoft.com/en-us/windows/win32/shell/folderitem
;		https://docs.microsoft.com/en-us/windows/win32/shell/folder
;both path bellow could open target file
;	::{20D04FE0-3AEA-1069-A2D8-XXXXXXXXXXXX}\\\?\usb#vid_12d1subclass_ff&prot_00#7&XXXXXXXX&2&0000#{6ac27878-a6fa-4155-ba85-XXXXXXXXXXXX}\SID-{10001,,XXXXXXXXXXXX}\{0000000B-0001-0001-0000-000000000000}\{0000016C-0001-0001-0000-000000000000}\{0000245F-0001-0001-0000-XXXXXXXXXXXX}
;		也出现过:
;			Windows 找不到“...”。请检查拼写并重试。
;	此电脑\RobertP\内部存储\DCIM\Camera\IMG_20210623_212002.jpg

F1::	;{test path
	;	GetDeviceFolder or from computer
	shell := ComObjCreate("Shell.Application")
	;~ if false	;try to comment this
		phone := GetDeviceFolder("RobertP")
	computer := shell.Namespace("::{20d04fe0-3aea-1069-a2d8-08002b30309d}")
	Loop{
		InputBox, outputVar,,% "Input path based on " (phone?"phone":"computer"),,,140,,,,,% outputVar
		if ErrorLevel
			Exit
		if(phone)
			folderItem:=phone.ParseName(outputVar)
		else
			folderItem:=computer.ParseName(outputVar)
		MsgBox % folderItem.Name?(folderItem.Name ", " (folderItem.IsFolder=-1?"folder":"file")):"not exist"
		;	support: "C:"/"C:\"
		;	un support: "C" / "RobertP" / "\C:“ / "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\\\?\usb#vid_12d1subclass_ff&prot_00#7&32e05499&2&0000#{6ac27878-a6fa-4155-ba85-f98f491d4f33}\SID-{10001,,246853664768}\{0000000B-0001-0001-0000-000000000000}\" (and first n part of it).
	}
	return
;}
;F1::	;{https://www.autohotkey.com/boards/viewtopic.php?t=6395
	;	also see: https://www.autohotkey.com/boards/viewtopic.php?t=17655
	;		CopyHere
	phone := GetDeviceFolder("RobertP")
	camera := phone.ParseName("内部存储\DCIM\Camera").GetFolder()
	;	https://docs.microsoft.com/en-us/windows/win32/shell/folder-parsename
	for item in camera.Items{
		items .= item.Name "`n"
		break
	}
	MsgBox % items

	GetDeviceFolder(deviceName) {
		shell := ComObjCreate("Shell.Application")
		computer := shell.Namespace("::{20d04fe0-3aea-1069-a2d8-08002b30309d}")
		for item in computer.Items
			;	https://docs.microsoft.com/en-us/windows/win32/shell/folderitem
			if item.Name = deviceName
				;	https://docs.microsoft.com/en-us/windows/win32/shell/folderitem-name
				return item.GetFolder()
	}
	return
;}
F2::	;{GetSelectPath
	path:=GetSelectPath()
	files:=""
	Loop % path.Length()
		files.="`n" path[A_Index]
	MsgBox % path.Folder  files
	;	桌面\此电脑\RobertP\内部存储\DCIM\Camera\
	;		IMG_20210623_211957.jpg
	;		IMG_20210623_212002.jpg
	return
;}
;F2::	;{https://www.autohotkey.com/boards/viewtopic.php?p=348411#p348411
	shellFolderView:=GetActiveWindowComObject()
	loop
	{
	   if (A_Index = 1)
	   {
			folder := shellFolderView.Folder
			;	https://docs.microsoft.com/en-us/windows/win32/shell/folder
			folderPath := folder.Title
	   }
	   folder := folder.ParentFolder
	   if (folder = "")
	   {
			folderPath := RegexReplace(folderPath, "^.+?\\")
			break
	   }
	   folderPath := folder.Title "\" folderPath
	}
	msgbox % folderPath
	;	result: 
	;		its address path: 此电脑\文档\AutoHotkey
	;		its folder path (at title bar): C:\Users\RobertLin\Documents\AutoHotkey
	;	other case, both path is: 此电脑\RobertP\内部存储\DCIM\Camera
	return
;}
;F3::	;{SelectedItems
	shellFolderView:=GetActiveWindowComObject()
	for item in shellFolderView.SelectedItems
	{	;https://docs.microsoft.com/en-us/windows/win32/shell/folderitems
		;https://docs.microsoft.com/en-us/windows/win32/shell/folderitem
		MsgBox % item.Name ", " item.Path
		;	can not "item.Title" (but "folder.Title"), otherwise got "Error:  0x80020006 - 未知名称。"
		;	https://docs.microsoft.com/en-us/windows/win32/shell/folderitem-name
		break
	}
	return
;}

GetActiveWindowComObject(hWnd:=""){
	hWnd := hWnd?hWnd:WinExist("A")
	;also see: Get paths of selected items in an explorer window.ahk
	for window in ComObjCreate("Shell.Application").Windows       ; ShellFolderView object: https://goo.gl/MhcinH
		if (hWnd = window.HWND) && (shellFolderView := window.Document)
			break
	return shellFolderView
}
GetSelectPath(hWnd:=""){
	path:={}
	shellFolderView:=GetActiveWindowComObject(hWnd)
	folder:=shellFolderView.Folder
	;	https://docs.microsoft.com/en-us/windows/win32/shell/folder
	folderPath:=folder.Title "\"
	while(folder:=folder.ParentFolder)
		folderPath:=folder.Title "\" folderPath
	path.Folder:=folderPath
	for item in shellFolderView.SelectedItems
		;	https://docs.microsoft.com/en-us/windows/win32/shell/folderitem
		path.Push(item.Name)
		;	cant "item.Path", which may use device path
	return path
}

;	#Include Get paths of selected items in an explorer window.ahk
;	;	could get select file by Explorer_GetSelected(), could not get path by Explorer_GetPath()
;	;	something like: ::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\\\?\usb#vid_12d1&subclass_ff&prot_00#7&32e05499&2&0000#{6ac27878-a6fa-4155-ba85-f98f491d4f33}\SID-{10001,,246853664768}\{0000000B-0001-0001-0000-000000000000}\{0000016C-0001-0001-0000-000000000000}\{0000245F-0001-0001-0000-000000000000}
;	;	part afront is path, could open as address

;lightroom （5） 无法识别到 手机卷，但可以导入（“复制为DNG”、“复制”、“移动”、“添加”）