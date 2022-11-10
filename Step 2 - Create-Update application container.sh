# Activate command print
set -o xtrace

# Add proxy configuration 
export no_proxy=localhost, 127.0.0.1
export https_proxy=http://proxy.etn.com:8080
export http_proxy=http://proxy.etn.com:8080

#Check if the LXC container is installed, if not install

if [[ ! $(dpkg -l lxc | grep ii 2>/dev/null) ]]; then
    sudo apt install lxc -y
    
    # Set the LXC network configuration
    
    echo "USE_LXC_BRIDGE=\"true\"" > /etc/default/lxc-net
    echo "" >> /etc/default/lxc-net
    echo "LXC_BRIDGE=\"$LXCBRIDGE\"" >> /etc/default/lxc-net
    echo "LXC_ADDR=\"$LXCADDR\"" >> /etc/default/lxc-net
    echo "LXC_NETMASK=\"$LXCMASK\"" >> /etc/default/lxc-net
    echo "LXC_NETWORK=\"$LXCNETWORK\"" >> /etc/default/lxc-net
    echo "LXC_DHCP_RANGE=\"$LXCDHCPRANGE\"" >> /etc/default/lxc-net
    echo "LXC_DHCP_MAX=\"$LXCDHCPMAX\"" >> /etc/default/lxc-net
    echo "LXC_DHCP_CONFILE=\"\"" >> /etc/default/lxc-net
    echo "LXC_DOMAIN=\"\"" >> /etc/default/lxc-net
    echo "" >> /etc/default/lxc-net
    echo "# Honor system's dnsmasq configuration" >> /etc/default/lxc-net
    echo "#LXC_DHCP_CONFILE=/etc/dnsmasq.conf" >> /etc/default/lxc-net
    
    # restart lxc services
    sudo service lxc restart
    sudo service lxc-net  restart
fi



#  IMPORTANT : Container application variables should be declared in the pipeline

# Check if the container already exists
if [[ ! $(sudo lxc-info -n $CONTAINERNAME 2>/dev/null) ]]; then
    sudo lxc-create -n $CONTAINERNAME -t debian -- -r bullseye
    
    #  IMPORTANT : Container application ip cnfiguration should be declared in the pipeline
    #              if not default configuration will be used 10.0.4.10/24 gateway 10.0.4.1
    echo "# Set the container configuration" > /var/lib/lxc/$CONTAINERNAME/config
    echo "" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "# Template used to create this container: /usr/share/lxc/templates/lxc-debian" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "# Parameters passed to the template: -r bullseye" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "# For additional config options, please look at lxc.container.conf(5)" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "# Uncomment the following line to support nesting containers:" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "#lxc.include = /usr/share/lxc/config/nesting.conf" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "# (Be aware this has security implications)" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.net.0.type = veth" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.net.0.hwaddr = 00:16:3e:" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.net.0.link = lxcbr0" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.net.0.flags = up" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.net.0.ipv4.address = $CONTAINERIPADDRESS/$CONTAINERIPMASK" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.net.0.ipv4.gateway = $CONTAINERIPGATEWAY" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.apparmor.profile = generated" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.apparmor.allow_nesting = 1" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.rootfs.path = dir:/var/lib/lxc/$CONTAINERNAME/rootfs" >> /var/lib/lxc/$CONTAINERNAME/config
    
    echo "# Common configuration" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.include = /usr/share/lxc/config/debian.common.conf" >> /var/lib/lxc/$CONTAINERNAME/config
    
    echo "# Container specific configuration" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.tty.max = 4" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.uts.name = $CONTAINERNAME" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.arch = amd64" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.pty.max = 1024" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "# Container start configuration" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.start.auto = 1" >> /var/lib/lxc/$CONTAINERNAME/config
    echo "lxc.start.delay = 0" >> /var/lib/lxc/$CONTAINERNAME/config
    
    # Check if the container is started, if yes, stop it.
    if [[ $(sudo lxc-info $CONTAINERNAME -s -H) == "RUNNING" ]]; then
        sudo lxc-stop $CONTAINERNAME
    fi
fi

# Start the container
sudo lxc-start $CONTAINERNAME

# Waiting for the network configuration
WaitingIpRetries=10
WaitingIpSleepDelay=3
WaitingIpIterator=1
while [ $WaitingIpIterator -lt $WaitingIpRetries ]
do
    if [[ ! $(sudo lxc-info $CONTAINERNAME -i -H) ]]; then
        echo "Ip adress not yet assigned, retry number " $WaitingIpIterator
        sleep $WaitingIpSleepDelay
    else
        echo "IP assigned successfully : " $(sudo lxc-info $CONTAINERNAME -i -H)
        WaitingIpIterator=$WaitingIpRetries
    fi
    WaitingIpIterator=$((WaitingIpIterator+1))
done

# Todo : If the ip not available after all this time, stop the release deployment and raise error