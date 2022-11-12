# Activate command print
set -o xtrace

# Check if sudo lib is installed, if not, install it
sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    set -o xtrace

    if [  ! \$(dpkg -l | grep -w rsyslog | grep ii 2>/dev/null) ]; then
        sudo apt update -y
        sudo apt install rsyslog -y
    fi

    # Check if curl lib is installed, if not, install it
    if [  ! /$(dpkg -l | grep -w libcurl4-openssl-dev | grep ii 2>/dev/null) ]; then
        sudo apt update -y
        sudo apt install libcurl4-openssl-dev -y
    fi

    # Check if curl lib is installed, if not, install it ( required for npm )
    if [  ! \$(dpkg -l | grep -w curl | grep ii 2>/dev/null) ]; then
        sudo apt update -y
        sudo apt install curl -y
    fi

    # Check if npm  is installed, if not, install it
    if [  ! \$(dpkg -l | grep -w npm | grep ii 2>/dev/null) ]; then
        sudo apt update -y
        sudo apt install npm -y
        npm config set cafile $CONTAINERCERTIFICATEDIRECTORY/$CONTAINERCERTIFICATENAME
    fi

    # Check if node package manager "n" is installed, if not, install it
    if [  ! \$(npm list -g | grep n@ 2>/dev/null) ]; then
        npm install -g n
    fi

    # Check if serve is installed, if not, install it
    if [  ! \$(npm list -g | grep serve@ 2>/dev/null) ]; then
        npm install -g serve
    fi

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