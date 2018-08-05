#!/bin/sh

# Inspiration: https://github.com/geerlingguy/macos-virtualbox-vm/issues/24
set -e

# set configuration variables
. config

[ -d "$TMPDIR" ] || mkdir -p "$TMPDIR"

# internal variables
TMP_MOUNT_OS=$TMPDIR/os
TMP_MOUNT_ESD="$TMPDIR/esd"
TMP_DMG_OS="$TMPDIR/os.dmg"
VDI_IMAGE_SIZE_BYTES=$(($VDI_IMAGE_SIZE_GB * 1024 * 1024 * 1024))

if [ -z "$ESD_IMAGE" -o ! -r "$ESD_IMAGE" ]; then
  echo "Installation media not found: '$ESD_IMAGE'" 1>&2
  echo "See instructions." 1>&2
  exit 1
fi

if [ -r "$VDI_IMAGE" ]; then
  echo "$VDI_IMAGE already exists.  Delete it and try again." 1>&2
  exit 1
fi

# cleanup output and intermediaries on bad exit
trap "
  hdiutil detach "$TMP_MOUNT_OS" 2>/dev/null || :
  hdiutil detach "$TMP_MOUNT_ESD" 2>/dev/null || :
  rm -f "$TMP_DMG_OS.sparseimage" "$VDI_IMAGE"
" SIGINT SIGHUP SIGQUIT SIGKILL SIGTERM

echo "Attaching input OS X installer image..."
hdiutil attach \
  -noverify \
  -nobrowse \
  -owners on \
  -mountpoint "$TMP_MOUNT_ESD" \
  "$ESD_IMAGE"

echo "Preparing temporary install destination: $TMP_MOUNT_OS ..."
hdiutil create \
  -size "${VDI_IMAGE_SIZE_GB}g" \
  -type SPARSE \
  -fs "HFS+J" \
  -volname "Macintosh HD" \
  -uid 0 \
  -gid 80 \
  -mode 1775 \
  "$TMP_DMG_OS"
hdiutil attach -noverify -mountpoint "$TMP_MOUNT_OS" -nobrowse -owners on "$TMP_DMG_OS.sparseimage"

echo "Installing macOS to $TMP_OS (takes a long time)..."
  # -verboseR \
installer \
  -dumplog \
  -pkg "$TMP_MOUNT_ESD/Packages/OSInstall.mpkg" \
  -target "$TMP_MOUNT_OS"

# detach (later reattach) to properly flush disk image
hdiutil detach "$TMP_MOUNT_OS"

echo "Exporting installed disk to $VDI_IMAGE (takes a long time)..."
MOUNTOUTPUT=$(hdiutil attach -noverify -mountpoint "$TMP_MOUNT_OS" -nobrowse -owners on "$TMP_DMG_OS.sparseimage")
DISK_DEV=$(grep GUID_partition_scheme <<< "$MOUNTOUTPUT" | cut -f1 | tr -d '[:space:]')
echo "DISK_DEV=$DISK_DEV"

mkdir -p $(dirname "$VDI_IMAGE") 2>/dev/null || :

# use progress viewer (homebrew, macport) if available
if PV=$(which pv) ; then
  cat "$DISK_DEV" | $PV -s "$VDI_IMAGE_SIZE_BYTES" | VBoxManage convertfromraw stdin "$VDI_IMAGE" "$VDI_IMAGE_SIZE_BYTES"
else
  cat "$DISK_DEV" | VBoxManage convertfromraw stdin "$VDI_IMAGE" "$VDI_IMAGE_SIZE_BYTES"
fi

hdiutil detach "$TMP_MOUNT_OS" 2>/dev/null || :
hdiutil detach "$TMP_MOUNT_ESD" 2>/dev/null || :
rm -f "$TMP_DMG_OS.sparseimage"
exit 0
