# Activate command print
set -o xtrace

#Check if the LXC container is installed, if not install

if [[ ! $(dpkg -l | grep -w lxc  | grep ii 2>/dev/null) ]]; then
    sudo apt install lxc -y
fi

#  IMPORTANT : Container application variables should be declared in the pipeline

# Check if the container already exists
if [[ ! $(sudo lxc-info -n $(ContainerName) 2>/dev/null) ]]; then
    sudo lxc-create -n $(ContainerName) -t debian -- -r bullseye
fi

#  IMPORTANT : Container application ip cnfiguration should be declared in the pipeline
#              if not default configuration will be used 10.0.4.10/24 gateway 10.0.4.1


echo "# Set the container configuration" > /var/lib/lxc/$(ContainerName)/config
echo "" >> /var/lib/lxc/$(ContainerName)/config
echo "# Template used to create this container: /usr/share/lxc/templates/lxc-debian" >> /var/lib/lxc/$(ContainerName)/config
echo "# Parameters passed to the template: -r bullseye" >> /var/lib/lxc/$(ContainerName)/config
echo "# For additional config options, please look at lxc.container.conf(5)" >> /var/lib/lxc/$(ContainerName)/config
echo "" >> /var/lib/lxc/$(ContainerName)/config
echo "# Uncomment the following line to support nesting containers:" >> /var/lib/lxc/$(ContainerName)/config
echo "#lxc.include = /usr/share/lxc/config/nesting.conf" >> /var/lib/lxc/$(ContainerName)/config
echo "# (Be aware this has security implications)" >> /var/lib/lxc/$(ContainerName)/config
echo "" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.net.0.type = veth" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.net.0.hwaddr = 00:16:3e:" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.net.0.link = lxcbr0" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.net.0.flags = up" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.net.0.ipv4.address = ${ContainerIpAddress}/${ContainerIpMask}" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.net.0.ipv4.gateway = ${ContainerIpGateway}" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.apparmor.profile = generated" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.apparmor.allow_nesting = 1" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.rootfs.path = dir:/var/lib/lxc/SmpApplication/rootfs" >> /var/lib/lxc/$(ContainerName)/config

echo "# Common configuration" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.include = /usr/share/lxc/config/debian.common.conf" >> /var/lib/lxc/$(ContainerName)/config

echo "# Container specific configuration" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.tty.max = 4" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.uts.name = SmpApplication" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.arch = amd64" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.pty.max = 1024" >> /var/lib/lxc/$(ContainerName)/config
echo "# Container start configuration" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.start.auto = 1" >> /var/lib/lxc/$(ContainerName)/config
echo "lxc.start.delay = 0" >> /var/lib/lxc/$(ContainerName)/config

# Check if the container is started, if yes, stop it.
if [[ $(sudo lxc-info SmpApplication -s -H) == "RUNNING" ]]; then
    sudo lxc-stop $(ContainerName)
fi

# Start the container
sudo lxc-start $(ContainerName)

# Waiting for the network configuration
WaitingIpRetries=10
WaitingIpSleepDelay=3
WaitingIpIterator=1
while [ $WaitingIpIterator -lt $WaitingIpRetries ]
do
    if [[ ! $(sudo lxc-info SmpApplication -i -H) ]]; then
        echo "Ip adress not yet assigned, retry number " $WaitingIpIterator
        sleep $WaitingIpSleepDelay
    else
        echo "IP assigned successfully : " $(sudo lxc-info SmpApplication -i -H)
        WaitingIpIterator=$WaitingIpRetries
    fi
    WaitingIpIterator=$((WaitingIpIterator+1))
done

# Install updates & upgrades
sudo lxc-attach -n $(ContainerName) -- bash -c '
apt update -y
apt upgrade -y'

# Todo : If the ip not available after all this time, stop the release deployment and raise error