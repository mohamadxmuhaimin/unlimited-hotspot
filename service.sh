#!/system/bin/sh
MODDIR=${0%/*}

# Failsafe: Incase these iptables entries were already present, remove them once.
for INTERFACE in "v4-rmnet_data+" "wlan1" "bt-pan"; do
    iptables -t mangle -D PREROUTING -i $INTERFACE -j TTL --ttl-inc 1
    iptables -t mangle -D POSTROUTING -o $INTERFACE -j TTL --ttl-inc 1
    ip6tables -t mangle -D PREROUTING ! -p icmpv6 -i $INTERFACE -j HL --hl-inc 1
    ip6tables -t mangle -D POSTROUTING ! -p icmpv6 -o $INTERFACE -j HL --hl-inc 1
done

# Bypass TTL/HL detections for only Tether device (server) -> Tethered To devices (client).
# WARNING: Routers (as the client) require their own TTL/HL increment script.
for INTERFACE in "v4-rmnet_data+" "wlan1" "bt-pan"; do
    iptables -t mangle -I PREROUTING -i $INTERFACE -j TTL --ttl-inc 1
    iptables -t mangle -I POSTROUTING -o $INTERFACE -j TTL --ttl-inc 1
    ip6tables -t mangle -I PREROUTING ! -p icmpv6 -i $INTERFACE -j HL --hl-inc 1
    ip6tables -t mangle -I POSTROUTING ! -p icmpv6 -o $INTERFACE -j HL --hl-inc 1
done
