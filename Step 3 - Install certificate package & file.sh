# Activate command print
set -o xtrace

# Install updates & upgrades
sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    set -o xtrace

    apt update -y
    apt upgrade -y

    # Check if sudo lib is installed, if not, install it

    set -o xtrace
    if [[ ! \$(dpkg -l ca-certificates | grep ii 2>/dev/null) ]]; then
        apt install ca-certificates -y
    fi"

# Install caCopy the Eaton certificate and loadit
sudo cp $EATONCERTIFICATE_SECUREFILEPATH  /proc/$(sudo lxc-info -n $CONTAINERNAME -p -H)/root/usr/local/share/ca-certificates/
sudo mkdir /proc/$(sudo lxc-info -n $CONTAINERNAME -p -H)/root/$CONTAINERCERTIFICATEDIRECTORY
sudo cp $EATONCERTIFICATE_SECUREFILEPATH  /proc/$(sudo lxc-info -n $CONTAINERNAME -p -H)/root/$CONTAINERCERTIFICATEDIRECTORY
sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    set -o xtrace
    update-ca-certificates"