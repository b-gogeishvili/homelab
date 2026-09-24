# 2026-08-08 13:33:50 by RouterOS 7.23.3
#
# mikrotik hex S

/interface bridge
add comment="LAN Bridge" name=bridge vlan-filtering=yes
add comment="WAN & IPTV" igmp-snooping=yes igmp-version=3 name=wan-bridge

/interface ethernet
set [ find default-name=ether1 ] comment="Homelab Switch"
set [ find default-name=ether2 ] comment="Personal Port"
set [ find default-name=ether3 ] comment="IPTV Box"
set [ find default-name=ether4 ] comment="ISP Port"
set [ find default-name=ether5 ] disabled=yes
set [ find default-name=sfp1 ] disabled=yes

/interface vlan
add comment="Homelab VLAN" interface=bridge name=homelab vlan-id=40
add comment="Personal VLAN" interface=bridge name=personal vlan-id=30
add comment="Wi-Fi VLAN" interface=bridge name=wi-fi vlan-id=50

/interface list
add name=LAN
add name=WAN

/ip pool
add name=lan-pool ranges=10.8.8.30-10.8.8.62
add name=personal-pool ranges=172.24.30.128-172.24.30.254
add name=homelab-pool ranges=172.24.40.192-172.24.40.254
add name=wi-fi-pool ranges=172.24.50.16-172.24.50.254

/ip dhcp-server
add address-pool=lan-pool interface=bridge name=lan-dhcp
add address-pool=personal-pool interface=personal name=personal-dhcp
add address-pool=homelab-pool interface=homelab name=homelab-dhcp
add address-pool=wi-fi-pool interface=wi-fi name=wi-fi-dhcp

/interface bridge port
add bridge=wan-bridge interface=ether4
add bridge=wan-bridge interface=ether3
add bridge=bridge interface=ether1
add bridge=bridge interface=ether2

/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface bridge vlan
add bridge=bridge comment=Personal tagged=ether1,bridge untagged=ether2 \
    vlan-ids=30
add bridge=bridge comment=Homelab tagged=ether1,bridge vlan-ids=40
add bridge=bridge comment=Wi-Fi tagged=ether1,bridge vlan-ids=50
/interface list member
add interface=bridge list=LAN
add interface=wan-bridge list=WAN
/ip address
add address=10.8.8.1/26 comment=LAN interface=bridge network=10.8.8.0
add address=172.24.30.1/24 interface=personal network=172.24.30.0
add address=172.24.40.1/24 interface=homelab network=172.24.40.0
add address=172.24.50.1/24 interface=wi-fi network=172.24.50.0
/ip dhcp-client
add comment=Magti interface=wan-bridge name=client1
/ip dhcp-server network
add address=10.8.8.0/26 dns-server=10.8.8.1,8.8.8.8 gateway=10.8.8.1
add address=172.24.30.0/24 dns-server=172.24.40.2,8.8.8.8 gateway=172.24.30.1
add address=172.24.40.0/24 dns-server=172.24.40.2,8.8.8.8 gateway=172.24.40.1
add address=172.24.50.0/24 dns-server=172.24.40.2,8.8.8.8 gateway=172.24.50.1
/ip firewall address-list
add address=172.24.30.0/24 comment="personal network" list=whitelist
add address=10.8.8.0/26 comment="lan network" list=whitelist
/ip firewall filter
add action=drop chain=input comment="drop blacklist" log=yes log-prefix=\
    IN-BLACKLIST src-address-list=blacklist
add action=accept chain=input comment="accept established,related,untracked" \
    connection-state=established,related,untracked
add action=drop chain=input comment="drop invalid" connection-state=invalid \
    log=yes log-prefix=IN-INVALID
add action=add-src-to-address-list address-list=blacklist \
    address-list-timeout=1w chain=input comment="detect port scanners" \
    protocol=tcp psd=21,3s,3,1
add action=accept chain=input comment="allow zenbook" src-mac-address=\
    6C:2F:80:F4:F5:EC
add action=accept chain=input comment="allow wifi DHCP" dst-port=67 protocol=\
    udp src-address=172.24.50.0/24
add action=accept chain=input comment="allow wifi DNS TCP" dst-port=53 \
    protocol=tcp src-address=172.24.50.0/24
add action=accept chain=input comment="allow wifi DNS UDP" dst-port=53 \
    protocol=udp src-address=172.24.50.0/24
add action=drop chain=input comment="block winbox access from lab" dst-port=\
    8291 log=yes log-prefix=IN-BLOCK-WINBOX-LAB protocol=tcp src-address=\
    172.24.40.0/24
add action=drop chain=input comment="block ssh access from lab" dst-port=2202 \
    log=yes log-prefix=IN-BLOCK-SSH-LAB protocol=tcp src-address=\
    172.24.40.0/24
add action=drop chain=input comment="block wifi to router" log=yes \
    log-prefix=IN-BLOCK-WIFI src-address=172.24.50.0/24
add action=drop chain=input comment="block everything else" \
    in-interface-list=WAN log=yes log-prefix=IN-BLOCK-WAN
add action=fasttrack-connection chain=forward comment=\
    "fast-track for established,related" connection-state=established,related
add action=accept chain=forward comment="accept established,related" \
    connection-state=established,related
add action=drop chain=forward comment="block wifi to lan" dst-address=\
    10.8.8.0/26 log=yes log-prefix=FWD-WIFI-TO-LAN src-address=172.24.50.0/24
add action=drop chain=forward comment="block wifi to personal" dst-address=\
    172.24.30.0/24 log=yes log-prefix=FWD-WIFI-TO-PERSONAL src-address=\
    172.24.50.0/24
add action=drop chain=forward comment="block lab to lan" dst-address=\
    10.8.8.0/26 log=yes log-prefix=FWD-LAB-TO-LAN src-address=172.24.40.0/24
add action=drop chain=forward comment="block lab to personal" dst-address=\
    172.24.30.0/24 log=yes log-prefix=FWD-LAB-TO-PERSONAL src-address=\
    172.24.40.0/24
add action=drop chain=forward comment="block lab to wifi" dst-address=\
    172.24.50.0/24 log=yes log-prefix=FWD-LAB-TO-WIFI src-address=\
    172.24.40.0/24
add action=drop chain=forward comment="drop invalid" connection-state=invalid \
    log=yes log-prefix=FWD-INVALID
add action=drop chain=forward comment=\
    "drop access to clients behind NAT from WAN" connection-nat-state=!dstnat \
    connection-state=new in-interface-list=WAN log=yes log-prefix=\
    FWD-BLOCK-WAN
/ip firewall nat
add action=masquerade chain=srcnat out-interface-list=WAN
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set ssh address=10.8.8.0/26,172.24.30.0/24,172.24.50.0/24 port=2202
set winbox address=10.8.8.0/26,172.24.30.0/24,172.24.50.0/24
set api disabled=yes
set api-ssl disabled=yes
/ip ssh
set strong-crypto=yes
/ipv6 nd
# automatic dns option advertising is not started, re-apply dns config
set [ find default=yes ] advertise-dns=yes
/system clock
set time-zone-name=Asia/Tbilisi
/system ntp client
set enabled=yes
/system ntp client servers
add address=time.cloudflare.com
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
/tool sniffer
set file-name=sniff-cam filter-interface=bridge
