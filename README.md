# Pump Up the Volume

A generic shell script for creating an automagically mountable case sensitive volume in OSX.<br>
Sourced originally from a former colleague, but I've adapted this solution for a wider range of practical install scenarios.

## Why would I want to do this?

Primarily to resolve this conflict:

1. OSX uses case-insensitive volumes (and actually warns you not to use case-sensitive volumes for system files.)  Production systems almost always use case-sensitive file systems (think Linux).  Shuffling your code between these environments creates the possibility of a filename collision.
2. TimeMachine insists that you be consistent for all your disks, and choose one type of case sensitivity.  As OSX recommends case-sensitive volumes, it makes sense to stick with this.  Unfortunately this is at odds with condition 1.

Pump-Up-The-Volume allows you to create a TimeMachine-friendly development volume that will be compatible with your prod environment.  It will act as a transparent case-sensitive folder, and TimeMachine will archive the sparsebundle allowing you to roll back if you need to.

## Configuration:

You'll need to set a couple of important environment variables:

1.  WORKSPACE -- The location of the raw image file that will contain the case-sensitive file system.
2.  MOUNTPOINT -- The location where the image file will be mounted.
3.  VOLUME_NAME -- The name of the volume itself (how OSX will present it.)
4.  VOLUME_SIZE -- The size of the volume.
5.  AUTOMOUNT -- The location to install the automount script that will be executed on system start. (see example.)

<b>Note: Use ```sudo -E``` to ensure the variables are passed to the sudo environment.</b>

## Usage Example:

```
    export WORKSPACE="/Volumes/Projects/.workspace.sparseimage"
    export MOUNTPOINT="${HOME}/workspace"
    export VOLUME_NAME="workspace"
    export VOLUME_SIZE="10g"
    export AUTOMOUNT="${HOME}/bin"
    sudo -E ./pump.sh install
```