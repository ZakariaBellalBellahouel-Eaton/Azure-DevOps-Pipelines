# Activate command print
set -o xtrace

#Get the Ip Adresse
if [[ ! $(iptables -C PREROUTING -t nat -i $HOSTNETWORKINTERFACENAME -p tcp --dport 13000 -j DNAT --to-destination $CONTAINERIPADDRESS:$CONTAINERPXMC3000APPLICATIONPORT  2>/dev/null) ]]; then
    iptables -A PREROUTING -t nat -i $HOSTNETWORKINTERFACENAME -p tcp --dport $HOSTNETWORKAPPLICATIONPORTTOOPEN -j DNAT --to-destination $CONTAINERIPADDRESS:$CONTAINERPXMC3000APPLICATIONPORT 
fi

if [[ ! $(iptables -C FORWARD -p tcp -d $CONTAINERIPADDRESS --dport $CONTAINERPXMC3000APPLICATIONPORT  -j ACCEPT 2>/dev/null) ]]; then
    iptables -A FORWARD -p tcp -d $CONTAINERIPADDRESS --dport $CONTAINERPXMC3000APPLICATIONPORT  -j ACCEPT
fi

if [[ ! $(iptables -C POSTROUTING -t nat -s $CONTAINERIPADDRESS -o $HOSTNETWORKINTERFACENAME -j MASQUERADE 2>/dev/null) ]]; then
    iptables -A POSTROUTING -t nat -s $CONTAINERIPADDRESS -o $HOSTNETWORKINTERFACENAME -j MASQUERADE
fi

# Persist rule for boot
iptables-save > /etc/iptables/rules.v4