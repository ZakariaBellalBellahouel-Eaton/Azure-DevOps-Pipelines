# Activate command print
set -o xtrace

#Check if the LXC container is installed, if not install

if [[ ! $(dpkg -l lxc | grep ii 2>/dev/null) ]]; then
    sudo apt install lxc -y
    
    # Set the LXC network configuration
    
    sudo sh -c "echo \"USE_LXC_BRIDGE=\"true\"\" > /etc/default/lxc-net"
    sudo sh -c "echo \"\" >> /etc/default/lxc-net"
    sudo sh -c "echo \"LXC_BRIDGE=\"$LXCBRIDGE\"\" >> /etc/default/lxc-net"
    sudo sh -c "echo \"LXC_ADDR=\"$LXCADDR\"\" >> /etc/default/lxc-net"
    sudo sh -c "echo \"LXC_NETMASK=\"$LXCMASK\"\" >> /etc/default/lxc-net"
    sudo sh -c "echo \"LXC_NETWORK=\"$LXCNETWORK\"\" >> /etc/default/lxc-net"
    sudo sh -c "echo \"LXC_DHCP_RANGE=\"$LXCDHCPRANGE\"\" >> /etc/default/lxc-net"
    sudo sh -c "echo \"LXC_DHCP_MAX=\"$LXCDHCPMAX\"\" >> /etc/default/lxc-net"
    sudo sh -c "echo \"LXC_DHCP_CONFILE=\"\"\" >> /etc/default/lxc-net"
    sudo sh -c "echo \"LXC_DOMAIN=\"\"\" >> /etc/default/lxc-net"
    sudo sh -c "echo \"\" >> /etc/default/lxc-net"
    sudo sh -c "echo \"# Honor system's dnsmasq configuration\" >> /etc/default/lxc-net"
    sudo sh -c "echo \"#LXC_DHCP_CONFILE=/etc/dnsmasq.conf\" >> /etc/default/lxc-net"
    
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
    sudo sh -c  "echo \"# Set the container configuration\" > /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"# Template used to create this container: /usr/share/lxc/templates/lxc-debian\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"# Parameters passed to the template: -r bullseye\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"# For additional config options, please look at lxc.container.conf(5)\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"# Uncomment the following line to support nesting containers:\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"#lxc.include = /usr/share/lxc/config/nesting.conf\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"# (Be aware this has security implications)\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.net.0.type = veth\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.net.0.hwaddr = $CONTAINERNETWORKMACADDRESS \" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.net.0.link = lxcbr0\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.net.0.flags = up\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.net.0.ipv4.address = $CONTAINERIPADDRESS/$CONTAINERIPMASK\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.net.0.ipv4.gateway = $CONTAINERIPGATEWAY\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.apparmor.profile = generated\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.apparmor.allow_nesting = 1\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.rootfs.path = dir:/var/lib/lxc/$CONTAINERNAME/rootfs\" >> /var/lib/lxc/$CONTAINERNAME/config"
    
    sudo sh -c  "echo \"# Common configuration\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.include = /usr/share/lxc/config/debian.common.conf\" >> /var/lib/lxc/$CONTAINERNAME/config"
    
    sudo sh -c  "echo \"# Container specific configuration\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.tty.max = 4\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.uts.name = $CONTAINERNAME\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.arch = amd64\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.pty.max = 1024\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"# Container start configuration\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.start.auto = 1\" >> /var/lib/lxc/$CONTAINERNAME/config"
    sudo sh -c  "echo \"lxc.start.delay = 0\" >> /var/lib/lxc/$CONTAINERNAME/config"
    
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