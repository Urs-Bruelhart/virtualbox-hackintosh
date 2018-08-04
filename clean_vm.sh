#!/bin/sh

VM="MacOS High Sierra"

set -e
set -x
VBoxManage controlvm "$VM" poweroff 2>/dev/null || :
VBoxManage unregistervm "$VM" --delete 2>/dev/null || :
rm -f macos-hs-live.vdi
