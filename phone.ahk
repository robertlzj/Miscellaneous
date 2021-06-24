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

F1::	;{test path (parse name)
	;	GetDeviceFolder or from computer
	Loop{
		InputBox, outputVar,,% "Input path (computer volume or device)",,,140,,,,,% outputVar
		if ErrorLevel
			Exit
		namespace:=GetNamespace(outputVar)
		;	outputVar may change.
		;	path "C:\XXX" is based on namespace "此电脑"
		;	path "RobertP\内部存储" is based on namespace "RobertP", seems path should be "内部存储", but could not omit device.
		path:=outputVar
		folderItem:=namespace.ParseName(path)
		;	
		MsgBox %  folderItem.Path?(folderItem.Path ", " folderItem.Name ", " (folderItem.IsFolder=-1?"folder":"file")):"not exist"
		;	support: "C:", "C:\"
		;	un support: "C", "RobertP", "\C:“, "本地磁盘 (C:)", "百度网盘", "迅雷下载", "下载", "RobertL",  "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\\\?\usb#vid_12d1subclass_ff&prot_00#7&32e05499&2&0000#{6ac27878-a6fa-4155-ba85-f98f491d4f33}\SID-{10001,,246853664768}\{0000000B-0001-0001-0000-000000000000}\" (and first n part of it).
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
	;	桌面\此电脑\本地磁盘 (C:)\XXX
	;		Cant use "桌面\此电脑\本地磁盘 (C:)" as path, but use "C:\XXX"
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
F3::	;{rename
	path:=GetSelectPath()
	if(path.Length()!=1)
		return
	paths:=path.Folder (name:=path[1])
	;~ method2:="cant handle device"
	InputBox, outputVar, Rename, % "Select file path is " paths "`nUse method " (method2?2:1) "`nNew name",,,180,,,,,% name
	if(ErrorLevel)
		return
	if(method2){
		RegExMatch(paths,"O)(.+\\)(.+?)$",found)
		folderPath:=found[1]
		fileName:=found[2]
		Rename2(folderPath,fileName,outputVar)
	}else
		Rename(paths,outputVar)
	return
;}

GetDeviceFolder(deviceName) {
	static shell := ComObjCreate("Shell.Application")
	static computer := shell.Namespace("::{20d04fe0-3aea-1069-a2d8-08002b30309d}")
	;	https://docs.microsoft.com/en-us/windows/win32/shell/shell-namespace
	;cant computer.ParseName(deviceName)
	for item in computer.Items
		;	https://docs.microsoft.com/en-us/windows/win32/shell/folderitem
		if item.Name = deviceName
			;	https://docs.microsoft.com/en-us/windows/win32/shell/folderitem-name
			return item.GetFolder()
}
GetActiveWindowComObject(hWnd:=""){
	static shell:=ComObjCreate("Shell.Application")
	hWnd := hWnd?hWnd:WinExist("A")
	;also see: Get paths of selected items in an explorer window.ahk
	for window in shell.Windows       ; ShellFolderView object: https://goo.gl/MhcinH
		if (hWnd = window.HWND) && (shellFolderView := window.Document)
			break
	return shellFolderView
	;	https://docs.microsoft.com/en-us/windows/win32/shell/shellfolderview
}
GetSelectPath(hWnd:=""){
	path:={}
	shellFolderView:=GetActiveWindowComObject(hWnd)
	folder:=shellFolderView.Folder
	;	https://docs.microsoft.com/en-us/windows/win32/shell/folder
	folderPath:=""
	if((title1:=folder.Title)!="此电脑"){
		while((folder:=folder.ParentFolder) && (title2:=folder.Title)!="此电脑")
			;	桌面\此电脑\
			folderPath:=title1 "\" folderPath
			,title1:=title2
		if RegExMatch(title1,"O)([A-Z]:)",found)	;volume
			folderPath:=found[1] "\" folderPath
		else	;device
			folderPath:=title1 "\" folderPath
	}
	path.Folder:=folderPath
	for item in shellFolderView.SelectedItems
		;	https://docs.microsoft.com/en-us/windows/win32/shell/folderitem
		path.Push(item.Name)
		;	cant "item.Path", which may use device path
	return path
}
Rename(path,name){
	static shell:=ComObjCreate("Shell.Application")
	namespace:=GetNamespace(path)
	folderItem:=namespace.ParseName(path)
	;	https://docs.microsoft.com/en-us/windows/win32/shell/folder-parsename
	if not folderItem
		throw A_ThisFunc ". Cant parse path """ path """"
	try
		folderItem.Name:=name
		;	may prompt duplicate name
}
Rename2(folderPath,origName,newName){
	;	can only access volume (not device)
	static shell:=ComObjCreate("Shell.Application")
	folder:=shell.Namespace(folderPath)
	;	https://docs.microsoft.com/en-us/windows/win32/shell/shell-namespace
	if not folder
		;	unsupport "此电脑\RobertP\内部存储\.."(as title bar shows), "RobertP\内部存储\.."(as address bar shows)
		;	for device, must use path (not device name)?
		;	could "::{20d04fe0-3aea-1069-a2d8-08002b30309d}\C:\XXX"
		;	could not "::{20d04fe0-3aea-1069-a2d8-08002b30309d}\RobertP"
		throw A_ThisFunc ". Cant parse folder path """ folderPath """"
	folderItem:=folder.ParseName(origName)
	;	https://docs.microsoft.com/en-us/windows/win32/shell/folder-parsename
	if not folderItem
		throw A_ThisFunc ". Cant parse file name """ origName """"
	try
		folderItem.Name:=newName
		;	may prompt duplicate name
}
GetNamespace(ByRef path){
	static shell:=ComObjCreate("Shell.Application")
	static coumputer:=shell.Namespace("::{20d04fe0-3aea-1069-a2d8-08002b30309d}")
	if(path~=".:\\")	;volume
		;	or "此电脑" (wont appear at title bar)
		namespace:=coumputer
		;	https://docs.microsoft.com/en-us/windows/win32/shell/shell-namespace
	else{
		if not RegExMatch(path,"O)^(?:此电脑\\)?(.+?)\\(.+)",found)
			;	"此电脑" will appear at title bar
			throw "Cant parse path, which is neither volume or device."
		deviceName:=found[1]
		if(not device:=GetDeviceFolder(deviceName))
			throw "Cant find device."
		namespace:=device
		path:=found[2]
	}
	return namespace
}

;	#Include Get paths of selected items in an explorer window.ahk
;	;	could get select file by Explorer_GetSelected(), could not get path by Explorer_GetPath()
;	;	something like: ::{20D04FE0-3AEA-1069-A2D8-08002B30309D}\\\?\usb#vid_12d1&subclass_ff&prot_00#7&32e05499&2&0000#{6ac27878-a6fa-4155-ba85-f98f491d4f33}\SID-{10001,,246853664768}\{0000000B-0001-0001-0000-000000000000}\{0000016C-0001-0001-0000-000000000000}\{0000245F-0001-0001-0000-000000000000}
;			"::{20D04FE0-3AEA-1069-A2D8-08002B30309D}" is "此电脑" 
;	;	part afront is path, could open as address

;lightroom （5） 无法识别到 手机卷，但可以导入（“复制为DNG”、“复制”、“移动”、“添加”）