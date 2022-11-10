# Activate command print
set -o xtrace

# Add proxy configuration 
export no_proxy=localhost, 127.0.0.1
export https_proxy=http://proxy.etn.com:8080
export http_proxy=http://proxy.etn.com:8080

#Get the Ip Adresse
if [[ ! $(sudo iptables -C PREROUTING -t nat -i $HOSTNETWORKINTERFACENAME -p tcp --dport $HOSTNETWORKAPPLICATIONPORTTOOPEN -j DNAT --to-destination $CONTAINERIPADDRESS:$CONTAINERPXMC3000APPLICATIONPORT  2>/dev/null) ]]; then
    sudo iptables -A PREROUTING -t nat -i $HOSTNETWORKINTERFACENAME -p tcp --dport $HOSTNETWORKAPPLICATIONPORTTOOPEN -j DNAT --to-destination $CONTAINERIPADDRESS:$CONTAINERPXMC3000APPLICATIONPORT 
fi

if [[ ! $(sudo iptables -C FORWARD -p tcp -d $CONTAINERIPADDRESS --dport $CONTAINERPXMC3000APPLICATIONPORT  -j ACCEPT 2>/dev/null) ]]; then
    sudo iptables -A FORWARD -p tcp -d $CONTAINERIPADDRESS --dport $CONTAINERPXMC3000APPLICATIONPORT  -j ACCEPT
fi

if [[ ! $(iptables -C POSTROUTING -t nat -s $CONTAINERIPADDRESS -o $HOSTNETWORKINTERFACENAME -j MASQUERADE 2>/dev/null) ]]; then
    sudo iptables -A POSTROUTING -t nat -s $CONTAINERIPADDRESS -o $HOSTNETWORKINTERFACENAME -j MASQUERADE
fi

# Persist rule for boot
sudo iptables-save > /etc/iptables/rules.v4