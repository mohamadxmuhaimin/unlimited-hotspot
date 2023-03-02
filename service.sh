#!/system/bin/sh
MODDIR=${0%/*}

# resetprop (without -n) = deletes a property then modifies it, this forces property_service to update that property immediately.

# Don't automatically insert 'dun' into the APN,
# which would persistently tell the telecom that tethering was used.
# At that point, only after a reboot and not getting 'dun' added again would mask it.
resetprop -v tether_dun_required 0

# Tethering hardware acceleration causes high ping issues on the Pixel 4a (5G).
resetprop -v tether_offload_disabled 1

# Don't tell the telecom to check if tethering is even allowed for your data plan.
resetprop -v net.tethering.noprovisioning true
resetprop -v tether_entitlement_check_state 0

# Don't apply iptables rules until Android has fully booted.
until [ $(getprop sys.boot_completed) -eq 1 ]; do
    sleep 1
done

# Bypass TTL/HL detections for only Tether device (server) -> Tethered To devices (client).
# WARNING: Routers (as the client) require their own TTL/HL increment script.
# Tethering interfaces -> rndis0: USB, wlan1: Wi-Fi, bt-pan: Bluetooth.
# -A: last rule in chain, -I: "head"/first rule in chain (by default).
for INTERFACE in "rndis0" "wlan1" "bt-pan"; do
    iptables -t mangle -A PREROUTING -i $INTERFACE -j TTL --ttl-inc 1
    iptables -t mangle -I POSTROUTING -o $INTERFACE -j TTL --ttl-inc 1
    ip6tables -t mangle -A PREROUTING ! -p icmpv6 -i $INTERFACE -j HL --hl-inc 1
    ip6tables -t mangle -I POSTROUTING ! -p icmpv6 -o $INTERFACE -j HL --hl-inc 1
done
