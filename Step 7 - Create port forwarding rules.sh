# Activate command print
set -o xtrace

#Get the Ip Adresse
if [[ ! $(iptables -C PREROUTING -t nat -i $(HostNetworkInterfaceName) -p tcp --dport 13000 -j DNAT --to-destination $(ContainerIpAddress):$(ContainerPXMC3000ApplicationPort)  2>/dev/null) ]]; then
    iptables -A PREROUTING -t nat -i $(HostNetworkInterfaceName) -p tcp --dport $(HostNetworkapplicationPortToOpen) -j DNAT --to-destination $(ContainerIpAddress):$(ContainerPXMC3000ApplicationPort)
fi

if [[ ! $(iptables -C FORWARD -p tcp -d $(ContainerIpAddress) --dport $(ContainerPXMC3000ApplicationPort) -j ACCEPT 2>/dev/null) ]]; then
    iptables -A FORWARD -p tcp -d $(ContainerIpAddress) --dport $(ContainerPXMC3000ApplicationPort) -j ACCEPT
fi

if [[ ! $(iptables -C POSTROUTING -t nat -s $(ContainerIpAddress) -o $(HostNetworkInterfaceName) -j MASQUERADE 2>/dev/null) ]]; then
    iptables -A POSTROUTING -t nat -s $(ContainerIpAddress) -o $(HostNetworkInterfaceName) -j MASQUERADE
fi

# Persist rule for boot
iptables-save > /etc/iptables/rules.v4