;SHOpenFolderAndSelectItems for explorer replacement program - AutoHotkey Community
;   https://www.autohotkey.com/boards/viewtopic.php?t=81910

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, force
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
; Explorer.exe /select,"C:\1\1.txt","C:\1\2.txt"

;----customer config begin----
folderPath=C:\1
files:=["1.txt", "2.txt"]
;----custormer config end----

COM_CoUninitialize()
COM_CoInitialize()

DllCall("shell32\SHParseDisplayName", "Wstr", folderPath, "Uint", 0, "Ptr*", pidl, "Uint", 0, "Uint", 0)
DllCall("shell32\SHBindToObject","Ptr",0,"Ptr",pidl,"Ptr",0,"Ptr"
    ,GUID4String(IID_IShellFolder,"{000214E6-0000-0000-C000-000000000046}")
    ,"Ptr*",pIShellFolder)

length:=files.Length()
VarSetCapacity(apidl, length * A_PtrSize, 0)
for k, v in files {
    ;IShellFolder:ParseDisplayName 
    DllCall(VTable(pIShellFolder,3),"Ptr", pIShellFolder,"Ptr",win_hwnd,"Ptr",0,"Wstr",v,"Uint*",0,"Ptr*",tmpPIDL,"Uint*",0)
    NumPut(tmpPIDL, apidl, (k - 1)*A_PtrSize, "Ptr")
}
DllCall("shell32\SHOpenFolderAndSelectItems", "Ptr", pidl, "UINT", length, "Ptr", &apidl, "Uint", 0)
;   SHOpenFolderAndSelectItems function (shlobj_core.h) - Win32 apps | Microsoft Docs
;       https://docs.microsoft.com/zh-cn/windows/win32/api/shlobj_core/nf-shlobj_core-shopenfolderandselectitems?redirectedfrom=MSDN
; "Uint",length,"Ptr",&apidl,"Ptr",GUID4String(IID_IContextMenu,"{000214E4-0000-0000-C000-000000000046}"),"UINT*",0,"Ptr*",pIContextMenu)
COM_CoUninitialize()
return

f3::
    COM_CoUninitialize()
    Exitapp
    
    COM_CoInitialize()
    {
        Return	DllCall("ole32\CoInitialize", "Uint", 0)
    }
    
    COM_CoUninitialize()
    {
        DllCall("ole32\CoUninitialize")
    }
    VTable(ppv, idx)
    {
        Return   NumGet(NumGet(1*ppv)+A_PtrSize*idx)
    }
    GUID4String(ByRef CLSID, String)
    {
        VarSetCapacity(CLSID, 16,0)
        return DllCall("ole32\CLSIDFromString", "wstr", String, "Ptr", &CLSID) >= 0 ? &CLSID : ""
    }