copy /a .\src\header-usb-source.cmd + /a .\src\set-this-pc-as.ps1 .\usb-image\sneakernet\set-this-pc-as-source.cmd
copy /a .\src\header-usb-dest.cmd   + /a .\src\set-this-pc-as.ps1 .\usb-image\sneakernet\set-this-pc-as-destination.cmd
copy .\src\copy-loop.ps1 .\usb-image\sneakernet\src\copy-loop.ps1
if not exist .\usb-image\sneakernet\src\settings.ini copy .\src\settings.ini .\usb-image\sneakernet\src\settings.ini

pause