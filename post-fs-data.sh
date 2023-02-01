#!/system/bin/sh
MODDIR=${0%/*}

# Block Android from inserting 'dun' into the APN.
# Yet another way Android shows the telecom that tethering is enabled.
settings put global tether_dun_required 0
