
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

Function DriveLetterFromSerial ($serial) {

  $letter = Get-Disk -SerialNumber $serial | 
    Get-Partition |
    Where-Object -Property DriveLetter |
    Select-object -ExpandProperty DriveLetter

   return "" + $letter
}

Function DriveSerialFromLetter ($letter) {
  $serial = get-partition -DriveLetter ("" + $letter).substring(0,1) | get-disk |   Select-object -ExpandProperty SerialNumber
  return $serial
}

Function EjectUSBByLetter($letter) {
    $driveName = DriveNameFromLetter $letter
    if ($driveName -ine "" ) {
        $driveEject = New-Object -comObject Shell.Application
        if (Test-Path $driveName) {
        Write-Output "ejecting $driveName"
            $driveEject.Namespace(17).ParseName($driveName).InvokeVerb("Eject")
            Start-Sleep 5
            if (Test-Path $driveName) {
                Start-Sleep 5  
                 if (Test-Path $driveName) {
                     $driveEject.Namespace(17).ParseName($driveName).InvokeVerb("Eject")
                     Start-Sleep 5  

                  }
            }
        }
    }
}

$IniHash = getSettings  ".\settings.ini"

$localPath = $IniHash.item("local")

if (Test-Path $localPath) {

    Write-Output "local path checks out: $localPath"


    $letter =  DriveLetterFromSerial (   $IniHash.item("serial") )

    if ($letter -ine "" ) {
      $driveName =  DriveNameFromLetter ($letter);
      if (Test-Path $driveName) {
      
            Write-Output "drive appears to be: $driveName"

            $transitPath = $driveName +  $IniHash.item("transit")
            if (Test-Path $transitPath) {
               Write-Output "transitPath checks out: $transitPath"
            } else {
                Write-Output "transitPath not found: $transitPath"

            }

            if ( $IniHash.item("mode") -eq "copy-to-usb" ) {
                ROBOCOPY $localPath $transitPath /MIR /XO /XA:SH /XD *$RECYCLE.BIN*
                EjectUSBByLetter($letter) 
            } else {
                 if ( $IniHash.item("mode") -eq "copy-from-usb" ) {
                    ROBOCOPY $transitPath $localPath /MIR /XO /XA:SH /XD *$RECYCLE.BIN*
                    EjectUSBByLetter($letter) 
                }
            }
 

      }

    }

  
    
} else {

    Write-Output "local path not found: $localPath"

}