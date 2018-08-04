#!/bin/sh

set -e

# Inspiration: https://github.com/geerlingguy/macos-virtualbox-vm/issues/24

# input
ESD_IMAGE='/Applications/Install macOS High Sierra.app/Contents/SharedSupport/InstallESD.dmg'
# output
VDI_IMAGE="macos-hs.vdi"

# How big a disk?
IMAGE_SIZE_GB=40
IMAGE_SIZE_BYTES=$(($IMAGE_SIZE_GB * 1024 * 1024 * 1024))

if [ ! -r "$ESD_IMAGE" ]; then
  echo "Installation media not found: '$ESD_IMAGE'" 1>&2
  echo "See instructions." 1>&2
  exit 1
fi

if [ -r "$VDI_IMAGE" ]; then
  echo "$VDI_IMAGE already exists.  Delete it and try again." 1>&2
  exit 1
fi


trap "hdiutil detach /tmp/os 2>/dev/null || :; rm -f /tmp/os.dmg.sparseimage || :; hdiutil detach /tmp/installesd 2>/dev/null || :" EXIT SIGINT SIGHUP SIGQUIT SIGKILL SIGTERM

echo "Attaching input OS X installer image..."
hdiutil attach \
  -noverify \
  -nobrowse \
  -owners on \
  -mountpoint /tmp/installesd \
  "$ESD_IMAGE"

echo "Preparing temporary install destination: /tmp/os ..."
hdiutil create \
  -size "${IMAGE_SIZE_GB}g" \
  -type SPARSE \
  -fs HFS+J \
  -volname "Macintosh HD" \
  -uid 0 \
  -gid 80 \
  -mode 1775 \
  /tmp/os.dmg
hdiutil attach -noverify -mountpoint /tmp/os -nobrowse -owners on /tmp/os.dmg.sparseimage

echo "Installing macOS to /tmp/os (takes a long time)..."
installer \
  -verboseR \
  -dumplog \
  -pkg "/tmp/installesd/Packages/OSInstall.mpkg" \
  -target "/tmp/os"

# detach (later reattach) to properly flush disk image
hdiutil detach /tmp/os

echo "Exporting installed disk to $VDI_IMAGE (takes a long time)..."
MOUNTOUTPUT=$(hdiutil attach -noverify -mountpoint /tmp/os -nobrowse -owners on /tmp/os.dmg.sparseimage)
DISK_DEV=$(grep GUID_partition_scheme <<< "$MOUNTOUTPUT" | cut -f1 | tr -d '[:space:]')
echo "DISK_DEV=$DISK_DEV"
cat "$DISK_DEV" | VBoxManage convertfromraw stdin "$VDI_IMAGE" "$IMAGE_SIZE_BYTES"
