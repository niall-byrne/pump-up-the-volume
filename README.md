# Pump Up the Volume

A generic shell script for creating an automagically mountable case sensitive volume in OSX
Sourced from a former colleague, and adapted for generic use.

## Why would I want to do this?

Primarily for two reasons:

1. OSX uses case-insensitive volumes by default, and this could cause unexpected side affects when running your code in production.
2. TimeMachine doesn't play nicely with dedicated case-sensitive volumes.  This provides a managable workaround.
3. Automatically remount the image every time you restart your computer, so it behaves like just another folder seemlessly.

## Configuration:

You'll need to set a couple of important environment variables:

1.  WORKSPACE -- The location of the raw image file that will contain the case-sensitive file system.
2.  MOUNTPOINT -- The location where the image file will be mounted.
3.  VOLUME_NAME -- The name of the volume itself (how OSX will present it.)
4.  VOLUME_SIZE -- The size of the volume.

<b>Note: Use export when setting the variables, to ensure they are passed to the sudo environment.</b>

## Usage Example:

```
    export WORKSPACE="/Volumes/Projects/.workspace.sparseimage"
    export MOUNTPOINT="${HOME}/workspace"
    export VOLUME_NAME="workspace"
    export VOLUME_SIZE="10g"
    sudo -E ./pump.sh install
```