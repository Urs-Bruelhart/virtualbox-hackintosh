#!/bin/sh

. config

VBoxManage controlvm "$VM_NAME" poweroff 2>/dev/null
VBoxManage unregistervm "$VM_NAME" --delete 2>/dev/null
rm -f "$VDI_LIVE_IMAGE"
