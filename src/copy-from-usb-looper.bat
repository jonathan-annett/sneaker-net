@echo off
set DEST=E:\sneakernet_dest
set USB=F

set STORE="%USB%:\sneakernet\files\"
set RFLAG="%USB%:\sneakernet\usb-flag.txt"

if exist ..\usb-flag.txt goto bad_invocation

if exist %RFLAG% if exist %STORE% if exist %DEST% goto usb_ready
echo Waiting for USB - insert when ready
ping 127.0.0.1 -n 6 > nul

:usb_not_ready
if exist %RFLAG% if exist %STORE% if exist %DEST% goto usb_ready
ping 127.0.0.1 -n 6 > nul
goto usb_not_ready

:bad_invocation
echo looks like you might be running this from the usb drive
echo please copy to a hard drive and run from there.
goto end_of_file

:usb_ready
echo Checking USB (%USB%:) against %DEST%

rem XCOPY %STORE%* %DEST% /D /S /E /Y

ROBOCOPY %STORE% %DEST% /MIR /XO /XA:SH /XD *$RECYCLE.BIN*

:retry_auto

Echo auto ejecting usb drive

cmd.exe /c ejectjs.bat %USB%

ping 127.0.0.1 -n 6 > nul

if exist %RFLAG% goto usb_eject_fail
echo ejected OK

Echo You can remove the usb drive now

goto usb_not_ready

:usb_eject_fail

Echo auto ejecting usb drive (second attempt)

cmd.exe /c ejectjs.bat %USB%

ping 127.0.0.1 -n 6 > nul

if exist %RFLAG% goto usb_eject_fail_retry
echo ejected OK

Echo You can remove the usb drive now

goto usb_not_ready

:usb_eject_fail_retry

Echo auto ejecting usb drive (third attempt)

cmd.exe /c ejectjs.bat %USB%

ping 127.0.0.1 -n 10 > nul

if exist %RFLAG% goto usb_eject_fail_retry_2
echo ejected OK
Echo You can remove the usb drive now

goto usb_not_ready


:usb_eject_fail_retry_2

echo could not eject %USB%:\ (tried 3 times)

ping 127.0.0.1 -n 5 > nul

goto retry_auto

:end_of_file
