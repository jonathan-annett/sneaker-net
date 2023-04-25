sneakernet
===
when the only connection between two computers is your feet, you need sneakernet.

<img src ="sneakernet.png">

one computer is designated the source, and that's the computer that you will always copy files from

the other is designated the destination (the computer you will always copy file to)

place the contents of usb-image onto a usb drive.

If your usb is drive E, you should end up with a folder "E:\sneakernet"

edit e:\sneakernet\src\settings.ini to nominate the source and destination folders

These are the folders on each computer that will be synced. by default these should both point to D:\

Insert the disk into the source computer, and open the sneakernet folder, and run "set-this-pc-as-source.cmd", with adminsitrator privilleges

this will create a folder on your desktop called "sneakernet" and a shortcut to a file in that folder

this inital step will also disable autorun on insert for all usb drives for that computer.

you can now press ctrl-alt-s to sync the files in the source folder to the usb

when it's done you should be able to repeat the process on the destination computer, choosing "set-this-pc-as-destination.cmd" to set that computer as the destination

ctrl-alt-s on that computer will sync from the usb to the destination folder.

transfering the disk between the two computers and pressing ctrl-alt-s will have the effect of syncing changed or new files to and from the usb

note that the script takes a note of the usb serial number and will only ever attempt to sync to/from that specific usb.


