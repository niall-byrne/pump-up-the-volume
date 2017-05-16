#!/bin/bash

# ------------------------------------------------------------
# Case Sensitive Development Mount
# ------------------------------------------------------------

# Configuration Check
[[ -z "${WORKSPACE}" ]] && echo "WORKSPACE variable unset." && exit 1
[[ -z "${MOUNTPOINT}" ]] && echo "MOUNTPOINT variable unset." && exit 1
[[ -z "${VOLUME_NAME}" ]] && echo "VOLUME_NAME variable unset." && exit 1
[[ -z "${VOLUME_SIZE}" ]] && echo "VOLUME_SIZE variable unset." && exit 1

root() {
    # Check for root
    if [[ $UID -ne 0 ]]; then
      echo 'This commands needs to be run as root.  Use sudo.'
      exit 1
    fi
}

# Create a sparse bundle with the correct parameters, as the original user
create() {
    root
    sudo -u $SUDO_USER bash -c "hdiutil create -type SPARSE -fs 'Case-sensitive Journaled HFS+' -size ${VOLUME_SIZE} -volname ${VOLUME_NAME} '${WORKSPACE}'"
}

# Mount the workspace volume on boot
automount() {
    root
    attach
    cat << EOF > /tmp/com.workspace.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>RunAtLoad</key>
        <true/>
        <key>Label</key>
        <string>com.workspace</string>
        <key>ProgramArguments</key>
        <array>
            <string>hdiutil</string>
            <string>attach</string>
            <string>-notremovable</string>
            <string>-nobrowse</string>
            <string>-mountpoint</string>
            <string>${MOUNTPOINT}</string>
            <string>${WORKSPACE}</string>
        </array>
    </dict>
</plist>
EOF
    cp /tmp/com.workspace.plist /Library/LaunchDaemons/com.workspace.plist
    rm /tmp/com.workspace.plist
}

# Unmount the workspace volume
detach() {
    m=$(hdiutil info | grep "${MOUNTPOINT}" | cut -f1)
    echo "Identified volume: $m"
    if [ ! -z "$m" ]; then
        hdiutil detach $m
        hdiutil eject $m
    fi
}

# Mount the workspace volume
attach() {
    root
    [[ -d "${MOUNTPOINT}" ]] && mkdir -p "${MOUNTPOINT}"
    hdiutil attach -notremovable -nobrowse -mountpoint "${MOUNTPOINT}" "${WORKSPACE}"
}

# Clean up the workspace volume
compact() {
    detach
    hdiutil compact "${WORKSPACE}" -batteryallowed
    attach
}

if [[ $1 == "install" ]]; then
    echo "This will install the volume to ${MOUNTPOINT}"

    # Step 1 Create the Volume
    echo -n "Creating case-insensitive volume ... "
    [[ ! -f "${WORKSPACE}" ]] && create
    echo "done."

    # Step 2 Mount the Volume
    echo -n "Mounting the volume ... "
    m=$(hdiutil info | grep "${MOUNTPOINT}" | cut -f1)
    [[ -z $m ]] && attach
    echo "done."

    # Step 3 Automount Enable
    echo -n "Enabling mount at boot ... "
    automount
    echo "done."

    echo
    echo
    echo "The volume is installed at: ${MOUNTPOINT}"
    echo

    exit 0

fi

if [[ $1 == "remove" ]]; then
    echo "This will remove the volume to ${MOUNTPOINT}"

    # Step 1 Unmount the Volume
    echo -n "Removing the volume ... "
    detach
    echo "done."

    # Step 2 Automount Disable
    echo -n "Disabling mount at boot ... "
    [[ -f /Library/LaunchDaemons/com.workspace.plist ]] && rm /Library/LaunchDaemons/com.workspace.plist
    echo "done."

    echo
    echo
    echo "The volume has been removed from: ${MOUNTPOINT}"
    echo

    exit 0

fi

echo "Usage:"
echo "sudo -E ./pump.sh install"
echo "sudo -E ./pump.sh remove"
