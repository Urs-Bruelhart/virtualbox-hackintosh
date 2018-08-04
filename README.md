# virtualbox-hackintosh - Set up MacOS High Sierra (10.13.4)

Create and run a virtualbox containing MacOs High Sierra (10.13.4)

This has been tested on a MacBookPro10,1 running MacOS 10.12.6 (Sierra).  Creating a VirtualBox virtual disk containing High Sierra is done on a Mac.
I only tested running the virtual machine using that disk on the Mac, but I have a feeling it would work on nearly any MacOS, Windows, or Linux box.

Note: I found a huge number of tutorial's, how-to's, and forum suggestions that did not result in a working machine.  Google for "macos on virtualbox" at your peril.  I also did not want to download a random VDI file off the internet whose provenance I did not trust.  This process uses just the official apple install media, and the official VirtualBox release, and no other dependencies.

## To make it work:

1. Download and install Virtualbox

Download VirtualBox from www.virtualbox.com.
Tested on version 5.2.16 for Mac.

2. Download MacOS High Sierra Installer

The file
`/Applications/Install MacOS High Sierra.app/Contents/SharedSupport/InstallESD.dmg`
must exist.  If it does not, then run the Install app.  This will
download the InstallESD.dmg file, and then prompt you to start the install
-- at which point you will quit out of the installer program without
installing. If you were to keep going, you'd be installing High
Sierra on your local machine.

3. Prepare the VDI disk image for VirtualBox

Run the command to prepare_vdi as a non-root admin user.  You will be asked for your password early in the process, to perform an installation, and then the install disk will be converted to VDI format for VirtualBox.

```
% ./prepare_vdi.sh /Applications/Install MacOS High Sierra.app
```

This creates a disk image containing the High Sierra install in macos-hs.vdi

4. Set up and run the virtual machine.

```
% ./run_vm.sh "High Sierra"
```

This will create a copy of the vdi (macos-hs-live.vdi) and launch the the VM on it.  The first argument is the name of the virtual machine.

You can then perform the initial set up steps, setting the timezone and createing the initial admin account, etc, just as you would with any new machine.

If you shut down the virtual machine and execute run_vm.sh again, it will pick up where you left off, off the live VDI disk.  If you run

```
% ./cleanup.sh
```
This will destroy the virtual machine, and delete the live file, so that on the next run, you'll start with a pristine factory reset machine.
