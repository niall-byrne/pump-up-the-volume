#!/usr/bin/env bash

# ------------------------------------------------------------
# Idempotent Unmount Script
# ------------------------------------------------------------

# Configuration
MOUNTPOINT="<<MOUNTPOINT>>"

# Requires root credentials
root() {
    # Check for root
    if [[ $UID -ne 0 ]]; then
      echo 'This commands needs to be run as root.  Use sudo.'
      exit 1
    fi
}

# Unmount the workspace volume
detach() {
    root
    m=$(hdiutil info | grep "${MOUNTPOINT}" | cut -f1)
    echo "Identified volume: $m"
    if [ ! -z "$m" ]; then
        hdiutil detach $m
        hdiutil eject $m
    else
        echo "The volume does not seem to be mounted."
    fi
}

detach