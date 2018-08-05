#!/bin/sh

set -e

. config

if [ ! -r "$VDI_IMAGE" ]; then
  echo "File not found: $VDI_IMAGE" 2>&1
  echo "See instructions." 2>&1
  exit 1
fi

# Inspired by: https://github.com/geerlingguy/macos-virtualbox-vm/issues/24
if [ ! -r "$VDI_LIVE_IMAGE" ]; then
  echo "Copying VDI snapshot to live disk..."
  cp "$VDI_IMAGE" "$VDI_LIVE_IMAGE"
fi

if VBoxManage createvm --name "$VM_NAME" --ostype "MacOS_64" --register 2>/dev/null ; then
  echo "Creating VM '$VM_NAME'..."
  VBoxManage storagectl "$VM_NAME" --name "SATA Controller" --add sata --controller IntelAHCI
  VBoxManage storageattach "$VM_NAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VDI_LIVE_IMAGE"
fi

VBoxManage modifyvm "$VM_NAME" --audiocontroller "hda"
VBoxManage modifyvm "$VM_NAME" --chipset "ich9"
VBoxManage modifyvm "$VM_NAME" --firmware "efi"
VBoxManage modifyvm "$VM_NAME" --cpus "2"
VBoxManage modifyvm "$VM_NAME" --hpet "on"
VBoxManage modifyvm "$VM_NAME" --keyboard "usb"
VBoxManage modifyvm "$VM_NAME" --memory "4096"
VBoxManage modifyvm "$VM_NAME" --mouse "usbtablet"
VBoxManage modifyvm "$VM_NAME" --vram "128"

# This works on my MacBookPro10,1 (2012), and purports to work on windows. In fact it may not be needed at all...
# Ref: https://www.wikigain.com/install-macos-high-sierra-virtualbox-windows/
VBoxManage modifyvm "$VM_NAME" --cpuidset  00000001 000106e5 00100800 0098e3fd bfebfbff
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/efi/0/Config/DmiSystemProduct" "iMac11,3"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/efi/0/Config/DmiSystemVersion" "1.0"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/efi/0/Config/DmiBoardProduct" "Iloveapple"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/smc/0/Config/DeviceKey" "ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc"
VBoxManage setextradata "$VM_NAME" "VBoxInternal/Devices/smc/0/Config/GetKeyFromRealSMC" 1

VBoxManage setextradata "$VM_NAME" VBoxInternal2/EfiGraphicsResolution "$VM_DISPLAY_SIZE"

echo "Starting VM..."
VBoxManage startvm "$VM_NAME"
