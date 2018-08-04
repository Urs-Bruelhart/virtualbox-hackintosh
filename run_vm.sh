#!/bin/sh

set -e

VM="MacOS High Sierra"
HARDDRIVE="macos-hs-live.vdi"

if [ ! -r macos-hs.vdi ]; then
  echo "File not found: macos-hs.vdi" 2>&1
  echo "See instructions." 2>&1
  exit 1
fi

# Ref: https://github.com/geerlingguy/macos-virtualbox-vm/issues/24

if [ ! -r "$HARDDRIVE" ]; then
  echo "Copying VDI snapshot to live disk..."
  cp macos-hs.vdi "$HARDDRIVE"
fi

if VBoxManage createvm --name "$VM" --ostype "MacOS_64" --register 2>&1 ; then
  echo "Creating VM..."
  VBoxManage storagectl "$VM" --name "SATA Controller" --add sata --controller IntelAHCI
  VBoxManage storageattach "$VM" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$HARDDRIVE"
fi

VBoxManage modifyvm "$VM" --audiocontroller "hda"
VBoxManage modifyvm "$VM" --chipset "ich9"
VBoxManage modifyvm "$VM" --firmware "efi"
VBoxManage modifyvm "$VM" --cpus "2"
VBoxManage modifyvm "$VM" --hpet "on"
VBoxManage modifyvm "$VM" --keyboard "usb"
VBoxManage modifyvm "$VM" --memory "4096"
VBoxManage modifyvm "$VM" --mouse "usbtablet"
VBoxManage modifyvm "$VM" --vram "128"

# This works on my MacBookPro10,1 (2012), and purports to work on windows.
# Ref: https://www.wikigain.com/install-macos-high-sierra-virtualbox-windows/
VBoxManage modifyvm "$VM" --cpuidset  00000001 000106e5 00100800 0098e3fd bfebfbff
VBoxManage setextradata "$VM" "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "iMac11,3"
VBoxManage setextradata "$VM" "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
VBoxManage setextradata "$VM" "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Iloveapple"
VBoxManage setextradata "$VM" "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
VBoxManage setextradata "$VM" "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 1

VBoxManage setextradata "$VM" VBoxInternal2/EfiGraphicsResolution 1440x900

echo "Starting VM..."
VBoxManage startvm "$VM"
