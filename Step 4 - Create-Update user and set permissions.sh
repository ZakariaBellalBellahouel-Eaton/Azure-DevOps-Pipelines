# Activate command print
set -o xtrace

# Add proxy configuration 
export no_proxy=localhost, 127.0.0.1
export https_proxy=http://proxy.etn.com:8080
export http_proxy=http://proxy.etn.com:8080

# Reset root password
sudo lxc-attach -n $CONTAINERNAME -- bash -c "
sed -i -e \"s/^root:[^:]\+:/root: $CONTAINERROOTPASSWORD /etc/shadow"

# Create new user with the required configuration
sudo lxc-attach -n $CONTAINERNAME -- bash -c "
if [ ! \$(id -u $CONTAINERPXMC3000USERNAME 2>/dev/null) ]; then

    useradd -m -d $CONTAINERPXMC3000HOMEFOLDER -p $CONTAINERPXMC3000PASSWORD -s /bin/bash $CONTAINERPXMC3000USERNAME

    # Check if the packages sudo is installed, if not install it and add user to sudoers
    if [  ! \$(dpkg-query -W -f='\${package}\n' sudo 2>/dev/null) ]; then
        apt update
        apt install sudo -y
        # Add $CONTAINERPXMC3000USERNAME to sudoers
        echo \"# Add $CONTAINERPXMC3000USERNAME to sudoers\" >> /etc/sudoers
        echo \"$CONTAINERPXMC3000USERNAME ALL=(ALL) NOPASSWD:ALL\" >> /etc/sudoers
    fi
fi"