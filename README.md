sneakernet
===

copies files from one computer to another automatically via a usb stick

unzip the zip file into the root of a usb drive to set up the file structure needed for a conveyance usb disk

copy the src folder to the source computer, and the destination computer

edit the batch `copy-to-usb-looper.bat` and `copy-from-usb-looper.bat` files as appropriate:

copy-to-usb-looper.bat: `SRC` and `USB` (this runs on source computer)
---

``` bat
set SRC=D:\
set USB=F
```

copy-from-usb-looper.bat: `DEST` and `USB` (this runs on destination computer)
---

``` bat
set DEST=D:\
set USB=F
```

note: if using a subfolder, don't end with a backlash. for example

``` bat
set SRC=D:\MYFILES
set USB=F
```

the `USB` variable is the letter of the usb disk. the script validates it by looking for the presence of a flag file under `USB:\sneakernet\usb-flag.txt`, so if you get it wrong all that will happen is the script won
t detect the usb being inserted.

run the appropriate batch files on each computer and move the conveyance usb disk between computers as instructed

(leave both scripts running)

updated/new files can be quickly transfered from source computer to destination computer by simply inserting disk in each computer

Attribution: uses usb eject code from  [npocmaka/batch.scripts](https://github.com/npocmaka/batch.scripts/blob/master/hybrids/jscript/ejectjs.bat) under [MIT license](https://github.com/npocmaka/batch.scripts/blob/master/LICENSE)

