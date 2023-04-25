@echo off & (For /F Delims^= %%a In ('CertUtil -HashFile %0 SHA1^|FindStr /VRC:"[^a-f 0-9]"') Do Set "PS1=%TEMP%\%%a.ps1" )
(if not exist %PS1% more +3 %0 > %PS1%) & (PowerShell.exe -ExecutionPolicy bypass -file %PS1%  -UsbScriptFile %0 -copyMode copy-from-usb -localItem destination & goto :EOF)
@@@@@@[ PowerShell Starts Here ]@@@@@@
