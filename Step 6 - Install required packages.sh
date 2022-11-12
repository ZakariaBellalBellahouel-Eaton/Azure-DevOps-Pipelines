# Activate command print
set -o xtrace

# Set proxy configuration for APT
sudo lxc-attach -n $CONTAINERNAME -- bash -c "
echo 'Acquire::http::Proxy \"http://proxy.etn.com:8080\";' > /etc/apt/apt.conf.d/02proxy
echo 'Acquire::https::Proxy \"http://proxy.etn.com:8080\";' >> /etc/apt/apt.conf.d/02proxy
"

# Install updates & upgrades
sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    set -o xtrace
    
    apt update -y
    apt upgrade -y"

# Check if rsyslog lib is installed, if not, install it
sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    if [  ! \$(dpkg -l | grep -w rsyslog | grep ii 2>/dev/null) ]; then
        sudo apt update -y
        sudo apt install rsyslog -y
    fi"

sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    # Check if curl lib is installed, if not, install it
    if [  ! /$(dpkg -l | grep -w libcurl4-openssl-dev | grep ii 2>/dev/null) ]; then
        sudo apt update -y
        sudo apt install libcurl4-openssl-dev -y
    fi"

sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    # Check if curl lib is installed, if not, install it ( required for npm )
    if [  ! \$(dpkg -l | grep -w curl | grep ii 2>/dev/null) ]; then
        sudo apt update -y
        sudo apt install curl -y
    fi"

sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    # Check if npm  is installed, if not, install it
    if [  ! \$(dpkg -l | grep -w npm | grep ii 2>/dev/null) ]; then
        sudo apt update -y
        sudo apt install npm -y
        npm config set cafile $CONTAINERCERTIFICATEDIRECTORY/$CONTAINERCERTIFICATENAME
    fi"

sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    # Check if node package manager "n" is installed, if not, install it
    if [  ! \$(npm list -g | grep n@ 2>/dev/null) ]; then
        npm install -g n
    fi"

sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    # Check if serve is installed, if not, install it
    if [  ! \$(npm list -g | grep serve@ 2>/dev/null) ]; then
        npm install -g serve
    fi"

#Set the certificate for npm
sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    npm config set cafile /usr/local/share/pxmc3000/certificates/Eaton_root_ca_2.crt"

sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    # Upgrade Node & Npm & Npx to the lastest stable version
    n stable

    # Install required local npm package
    cd $CONTAINERWEBSERVERDIRECTORY
    npm install sqlite3 express"

# Required packages to be installed on the host : iptables and iptables-persistent
# check if iptables is installed, if not, install it

if [  ! $(dpkg -l | grep -w iptables | grep ii 2>/dev/null) ]; then
    sudo apt update -y
    sudo apt install iptables -y
fi

# check if iptables-persistent is installed, if not, install it

if [  ! $(dpkg -l | grep -w iptables-persistent | grep ii 2>/dev/null) ]; then
    sudo apt update -y
    echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
    echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
    sudo apt install iptables-persistent -y
fi