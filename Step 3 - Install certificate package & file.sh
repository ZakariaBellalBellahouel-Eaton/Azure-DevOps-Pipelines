# Activate command print
set -o xtrace

# Install updates & upgrades
sudo lxc-attach -n $CONTAINERNAME -- bash -c '
apt update -y
apt upgrade -y'

# Check if sudo lib is installed, if not, install it
sudo lxc-attach -n $CONTAINERNAME -- bash -c '
    set -o xtrace
    if [  ! $(dpkg -l | grep ca-certificates | grep ii 2>/dev/null) ]; then
        sudo apt install ca-certificates -y
    fi'

# Install caCopy the Eaton certificate and loadit
sudo cp $(EatonCertificate.secureFilePath)  /proc/$(sudo lxc-info -n $CONTAINERNAME -p -H)/root/usr/local/share/ca-certificates/
sudo cp $(EatonCertificate.secureFilePath)  /proc/$(sudo lxc-info -n $CONTAINERNAME -p -H)/root/$(ContainerCertificateDirectory)
sudo lxc-attach -n $CONTAINERNAME -- bash -c '
    set -o xtrace
    update-ca-certificates'