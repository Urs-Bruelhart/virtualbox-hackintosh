# MacOS under VirtualBox

Scripts I use to build and run a VirtualBox virtual machine containing MacOS.

Tested and working with:
  MacOs High Sierra (10.13.4)
  VirtualBox 5.2.16 on MacBookPro10,1 (2012) running MacOS 10.12.6

Note: I found a huge number of tutorial's, how-to's, and forum
suggestions that did not result in a working machine.  Google for
"MacOS on VirtualBox" at your peril.  I also did not want to download
a random VDI file off the internet whose provenance I did not trust.
This process uses just the official apple install media, and the
official VirtualBox release, and no other dependencies.

## To make it work:

1. Download and install Virtualbox.

Download VirtualBox from www.virtualbox.com, and install it.

2. Download MacOS High Sierra Installer.

The file
`/Applications/Install MacOS High Sierra.app/Contents/SharedSupport/InstallESD.dmg`
must exist.  If it does not, then run the Install app.  This will
download the InstallESD.dmg file, and then prompt you to start the
install -- at which point you will quit out of the installer program
without installing. (If you were to keep going, you'd be installing
High Sierra on your local machine.)

3. Prepare the VDI disk image for VirtualBox.

Review the settings in the `config` file.

Run the prepare command as a non-root admin user.  You will be asked
for your own password early in the process, to perform an installation
as root, and then the install disk will be converted to VDI format
for VirtualBox.  The virtual disk has a maximum size of 40Gb (see
config file), but initially takes about 9Gb on the host machine.

```
% ./prepare_vdi.sh 
```

This creates a disk image (config default: `private/macos-hs.vdi`)
containing a factory fresh High Sierra install.  It takes about 20
minutes on my machine.

4. Set up and run the virtual machine.

```
% ./run_vm.sh
```

This will create a copy of the disk image (config default,
`private/macos-hs-live.vdi`) and boot a virtual machine off it.

You can then perform the initial set up steps, setting the timezone
and creating the initial admin account, etc, just as you would with
any new or factory-reset machine.  If you shut down the virtual
machine and execute run_vm.sh again, it will pick up where you left
off, using the live VDI disk.

```
% ./cleanup.sh
```

This will destroy the virtual machine, and delete the live file,
so that on the next `run_vm.sh`, you'll start with a pristine,
factory-reset machine.

