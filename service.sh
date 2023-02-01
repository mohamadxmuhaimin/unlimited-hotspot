#!/system/bin/sh
MODDIR=${0%/*}

# Failsafe: Incase these iptables entries were already present, remove them once.
iptables -t mangle -D PREROUTING -i v4-rmnet_data+ -j TTL --ttl-inc 1
iptables -t mangle -D POSTROUTING -o v4-rmnet_data+ -j TTL --ttl-inc 1
ip6tables -t mangle -D PREROUTING ! -p icmpv6 -i v4-rmnet_data+ -j HL --hl-inc 1
ip6tables -t mangle -D POSTROUTING ! -p icmpv6 -o v4-rmnet_data+ -j HL --hl-inc 1

# Bypass TTL/HL detections for only Tether device (server) -> Tethered To devices (client).
# WARNING: Routers (as the client) require their own TTL/HL increment script.
iptables -t mangle -I PREROUTING -i v4-rmnet_data+ -j TTL --ttl-inc 1
iptables -t mangle -I POSTROUTING -o v4-rmnet_data+ -j TTL --ttl-inc 1
ip6tables -t mangle -I PREROUTING ! -p icmpv6 -i v4-rmnet_data+ -j HL --hl-inc 1
ip6tables -t mangle -I POSTROUTING ! -p icmpv6 -o v4-rmnet_data+ -j HL --hl-inc 1
