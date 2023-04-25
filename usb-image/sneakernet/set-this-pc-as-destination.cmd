@echo off & (For /F Delims^= %%a In ('CertUtil -HashFile %0 SHA1^|FindStr /VRC:"[^a-f 0-9]"') Do Set "PS1=%TEMP%\%%a.ps1" )
(if not exist %PS1% more +3 %0 > %PS1%) & (PowerShell.exe -ExecutionPolicy bypass -file %PS1%  -UsbScriptFile %0 -copyMode copy-from-usb -localItem destination & goto :EOF)
@@@@@@[ PowerShell Starts Here ]@@@@@@

Param(
    [String]$UsbScriptFile=$MyInvocation.MyCommand.Source,
    [String]$localItem="source",
    [String]$copyMode="copy-to-usb"
)

function getSettings($filename){
    $INI = Get-Content $filename

    $IniHash = @{}
    ForEach($Line in $INI) {
      If ($Line -ne "" -and $Line.StartsWith("[") -ne $True) {
        $SplitArray = $Line.Split("=")
        $IniHash += @{$SplitArray[0] = $SplitArray[1]}
        $IniTemp += $Line
       }
    }

    return $IniHash
}
Function DriveNameFromLetter ($letter) {
    $coalesce  = "" + $letter
 
    if ($coalesce -eq "") {
       return ""
    }
    return $coalesce.substring(0,1) + ":\"
 }

 Function DriveSerialFromLetter ($letter) {
    $serial = get-partition -DriveLetter ("" + $letter).substring(0,1) | get-disk |   Select-object -ExpandProperty SerialNumber
    return $serial
 }
  
 Function DriveTypeByLetter($letter) {
    $driveName = DriveNameFromLetter $letter
    if ($driveName -ine "" ) {
        $driveEject = New-Object -comObject Shell.Application
        if (Test-Path $driveName) {
            $driveInfo = $driveEject.Namespace(17).ParseName($driveName);
            return $driveInfo.Type
        }
    }

    return "Unknown"
}

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if ($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) ) {

    $UsbSourceFolder=[System.IO.Path]::GetDirectoryName( $UsbScriptFile )
    $letter = DriveNameFromLetter ( $UsbSourceFolder )
    $driveType = DriveTypeByLetter ( $letter )

    if ($driveType -eq "USB Drive") {
        $serial = DriveSerialFromLetter ( $letter )
        $driveInfo = $driveType + " ($serial)"
        Write-Output "this script is on drive $letter, $driveInfo"

        $DesktopDir =  [Environment]::GetFolderPath("Desktop") 
        $SneakerNetDir =  $DesktopDir + "\sneakernet"
        $SneakerNetIni = $SneakerNetDir + "\settings.ini"

        $UsbSettingsIni = $UsbSourceFolder  + "\src\settings.ini"
        $usbSettings = getSettings($UsbSettingsIni)

    
        if (Test-Path $SneakerNetDir) {
            Write-Output "sneakernet directory already exists"
        } else {
            Write-Output "creating sneakernet directory"
            New-Item -ItemType Directory -Force -Path $SneakerNetDir
        }
        
        $local = $usbSettings.item($localItem)
        $transit = $usbSettings.item('transit')

        Set-Content -Path $SneakerNetIni -Value "serial=$serial"
        Add-Content -Path $SneakerNetIni -Value "local=$local"
        Add-Content -Path $SneakerNetIni -Value "transit=$transit"
        Add-Content -Path $SneakerNetIni -Value "mode=$copyMode"

        Write-Output "created $SneakerNetIni"

        #Get-Content "$UsbSourceFolder\src\header.cmd", "$UsbSourceFolder\src\copy-loop.ps1" | Set-Content  "$SneakerNetDir\copy-loop.cmd"
        Copy-Item "$UsbSourceFolder\src\copy-loop.ps1" "$SneakerNetDir\copy-loop.ps1"

        $ShortcutFile = $DesktopDir + "\sneakernet.lnk"
        $WScriptShell = New-Object -ComObject WScript.Shell
        $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
        $Shortcut.TargetPath = "powershell.exe"
        $Shortcut.WorkingDirectory  = $SneakerNetDir
        $Shortcut.Arguments = "-ExecutionPolicy bypass -file .\copy-loop.ps1"
        $Shortcut.Hotkey = "ALT+CTRL+S"
        $Shortcut.Save()

        $rkey = Get-Item HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer
    
        
        if  ($null -ne $rkey.getValue('NoDriveTypeAutoRun')   ) {
            Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoDriveTypeAutoRun  -value 255 -Verbose
            #Start-Process powershell -Verb runAs -ArgumentList '-ExecutionPolicy bypass -noexit -Command "Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoDriveTypeAutoRun  -value 255 -Verbose"'
        } else {
            New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoDriveTypeAutoRun  -value 255 -type Dword
            #Start-Process powershell -Verb runAs -ArgumentList '-ExecutionPolicy bypass -noexit -Command "New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoDriveTypeAutoRun  -value 255 -type Dword"'
        }

        if  ($null -ne $rkey.getValue('NoAutoRun')   ) {
            Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoAutoRun  -value 1 -Verbose
            #Start-Process powershell -Verb runAs -ArgumentList '-ExecutionPolicy bypass -noexit -Command "Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoAutoRun  -value 1 -Verbose"'
        } else {
            New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoAutoRun  -value 1 -type Dword
            #Start-Process powershell -Verb runAs -ArgumentList '-ExecutionPolicy bypass -noexit -Command "New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer -Name NoAutoRun  -value 1 -type Dword"'
        }
    }

} else {

    Write-Output "You need to run this script as Administrator"
    
}

Pause
