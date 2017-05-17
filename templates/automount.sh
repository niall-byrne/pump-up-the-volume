#!/bin/bash

# ------------------------------------------------------------
# Idempotent Mount Script
# ------------------------------------------------------------

# Configuration
MOUNTPOINT="<<MOUNTPOINT>>"
WORKSPACE="<<WORKSPACE>>"

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

    # Wait for the image file to become available (Perhaps OSX is mounting an encrypted partition)
    while True; do
          [[ -f "${WORKSPACE}" ]] && break
    done

    # Create the mountpoint if required
    [[ -d "${MOUNTPOINT}" ]] && mkdir -p "${MOUNTPOINT}"

    hdiutil attach -notremovable -nobrowse -mountpoint "${MOUNTPOINT}" "${WORKSPACE}"
}

attach

