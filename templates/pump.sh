#!/bin/bash

# ------------------------------------------------------------
# Idempotent Mount Script
# ------------------------------------------------------------

# Configuration
MOUNTPOINT="<<MOUNTPOINT>>"
WORKSPACE="<<WORKSPACE>>"
COMPACT=1

# Requires root credentials
root() {
    # Check for root
    if [[ $UID -ne 0 ]]; then
      echo 'This commands needs to be run as root.  Use sudo.'
      exit 1
    fi
}

# Mount the workspace volume
attach() {
    root

    m=$(hdiutil info | grep "${MOUNTPOINT}" | cut -f1)
    d=$(echo "$m" | cut -ds -f1,2)
    echo "Identified volume: $m"
    if [ -z "$m" ]; then

        # Wait for the image file to become available (Perhaps OSX is mounting an encrypted partition)
        while True; do
              [[ -f "${WORKSPACE}" ]] && break
        done

        # Create the mountpoint if required
        [[ -d "${MOUNTPOINT}" ]] && mkdir -p "${MOUNTPOINT}"

        hdiutil attach -nobrowse -mountpoint "${MOUNTPOINT}" "${WORKSPACE}" && echo "Volume has been mounted."

        # Clean up the workspace volume
        m=$(hdiutil info | grep "${MOUNTPOINT}" | cut -f1)
        d=$(echo "$m" | cut -ds -f1,2)
        [[ ${COMPACT} -eq 1 ]] && hdiutil compact "${d}" -batteryallowed

    else

        echo "The volume is already mounted."

    fi

}

attach

