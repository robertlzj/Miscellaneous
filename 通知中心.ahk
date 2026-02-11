#NoEnv
#SingleInstance Force
#Persistent

; 托盘图标提示文字
TrayIconPath := "Notifications(ActionCenter).ico"
Menu, Tray, Icon, %TrayIconPath%
Menu, Tray, Tip, 通知中心

; 设置托盘菜单
Menu, Tray, NoStandard
Menu, Tray, Add, 打开通知中心, OpenActionCenter
Menu, Tray, Add
Menu, Tray, Add, 连接 AirPods, ConnectAirPods
Menu, Tray, Add, 打开蓝牙设置, OpenBluetoothSettings
Menu, Tray, Add
Menu, Tray, Add, 退出, ExitApp

; 单击托盘图标执行打开操作中心
Menu, Tray, Default, 打开通知中心
Menu, Tray, Click, 1

return

OpenActionCenter:
    ; 方法1：发送 Win+A
    Send, #a

	; 方法2
	;~ Run, explorer.exe shell:::{3080F90D-D7AD-11D9-BD98-0000947B0257}
return

OpenBluetoothSettings:
    Run, ms-settings:bluetooth
return

ConnectAirPods:
	Send, #k
	;~ Run, btcom.exe -c -n"AirPods Pro"
	;	无法使用，可以在CMD下验证
	if false{
		DeviceName := "Fred的AirPods Pro"

		ps =
		(
		Add-Type -AssemblyName System.Runtime.WindowsRuntime

		$name = "%DeviceName%"

		$selector = "System.Devices.Aep.IsPaired:=True"
		$devices = [Windows.Devices.Enumeration.DeviceInformation]::FindAllAsync($selector).GetAwaiter().GetResult()

		foreach ($d in $devices) {
			if ($d.Name -like "*$name*") {
				$device = [Windows.Devices.Bluetooth.BluetoothDevice]::FromIdAsync($d.Id).GetAwaiter().GetResult()
				if ($device) {
					$device.GetRfcommServicesAsync().AsTask().Wait()
				}
			}
		}
		)

		RunWait, powershell -NoProfile -ExecutionPolicy Bypass -Command "%ps%",, Hide
	}
return

ExitApp:
    ExitApp
return
