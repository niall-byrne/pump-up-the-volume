#!/bin/bash

# ------------------------------------------------------------
# Case Sensitive Development Mount
# ------------------------------------------------------------

# Configuration Check
[[ -z "${WORKSPACE}" ]] && echo "WORKSPACE variable unset." && exit 1
[[ -z "${MOUNTPOINT}" ]] && echo "MOUNTPOINT variable unset." && exit 1
[[ -z "${VOLUME_NAME}" ]] && echo "VOLUME_NAME variable unset." && exit 1
[[ -z "${VOLUME_SIZE}" ]] && echo "VOLUME_SIZE variable unset." && exit 1
[[ -z "${AUTOMOUNT}" ]] && echo "AUTOMOUNT variable unset." && exit 1

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

    # Prepare the pump script
    sudo -u $SUDO_USER bash -c "sed \"s#<<MOUNTPOINT>>#${MOUNTPOINT}#g\" templates/pump.sh > ${AUTOMOUNT}/pump.1"
    sudo -u $SUDO_USER bash -c "sed \"s#<<WORKSPACE>>#${WORKSPACE}#g\" ${AUTOMOUNT}/pump.1 > ${AUTOMOUNT}/pump.sh"
    rm ${AUTOMOUNT}/pump.1
    chmod +x ${AUTOMOUNT}/pump.sh

    # Prepare the unpump script
    sudo -u $SUDO_USER bash -c "sed \"s#<<MOUNTPOINT>>#${MOUNTPOINT}#g\" templates/unpump.sh > ${AUTOMOUNT}/unpump.sh"
    chmod +x ${AUTOMOUNT}/unpump.sh


    # Install the LaunchDaemon plist
    sed "s#<<AUTOMOUNT>>#${AUTOMOUNT}/pump.sh#g" templates/com.workspace.plist > /Library/LaunchDaemons/com.workspace.plist
}

# Mount the workspace volume
attach() {
    root
    [[ -d "${MOUNTPOINT}" ]] && sudo -u $SUDO_USER mkdir -p "${MOUNTPOINT}"
    hdiutil attach -notremovable -nobrowse -mountpoint "${MOUNTPOINT}" "${WORKSPACE}"
}

if [[ $1 == "install" ]]; then
    echo "This will install the volume to ${MOUNTPOINT}"

    # Step 1 Create the Volume
    echo -n "Creating case-insensitive volume ... "
    [[ -f "${WORKSPACE}" ]] && echo "Already Exists"
    [[ ! -f "${WORKSPACE}" ]] && create && echo "done."

    # Step 2 Mount the Volume
    echo -n "Mounting the volume ... "
    m=$(hdiutil info | grep "${MOUNTPOINT}" | cut -f1)
    [[ -z $m ]] && attach && echo "done."
    [[ ! -z $m ]] && echo "already mounted."

    # Step 3 Automount Enable

    m=$(hdiutil info | grep "${MOUNTPOINT}" | cut -f1)
    [[ -z $m ]] && echo "MOUNT FAILED, CANNOT ENABLE AUTOMOUNT." && exit 1

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
echo "sudo -E ./inflate.sh install"
echo "sudo -E ./inflate.sh remove"
