# Activate command print
set -o xtrace

# Reset root password
sudo lxc-attach -n $(ContainerName) -- bash -c '
sed -i -e "s/^root:[^:]\+:/root:$(ContainerRootPassword):/" /etc/shadow'

# Create new user with the required configuration
sudo lxc-attach -n $(ContainerName) -- bash -c '
if [ ! $(id -u $(ContainerPXMC3000Username) 2>/dev/null)]; then

    useradd -m -d $(ContainerPXMC3000HomeFolder) -p $(ContainerRootPassword) -s /bin/bash $(ContainerPXMC3000Username)

    # Check if the packages sudo is installed, if not install it and add user to sudoers
    if [  ! $(dpkg-query -W -f='${package}\n' sudo 2>/dev/null) ]; then
        apt update
        apt install sudo -y
        # Add $(ContainerPXMC3000Username) to sudoers
        echo "# Add $(ContainerPXMC3000Username) to sudoers" >> /etc/sudoers
        echo "$(ContainerPXMC3000Username) ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    fi
fi'