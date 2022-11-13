# Activate command print
set -o xtrace

# Set proxy configuration for APT
sudo echo 'Acquire::http::Proxy \"http://proxy.etn.com:8080\";' > /etc/apt/apt.conf.d/02proxy
sudo echo 'Acquire::https::Proxy \"http://proxy.etn.com:8080\";' >> /etc/apt/apt.conf.d/02proxy

# Install updates & upgrades
sudo apt update -y
sudo apt upgrade -y

# Check if sudo lib is installed, if not, install it
if [[ ! "$(dpkg -l ca-certificates | grep ii 2>/dev/null)" ]]; then
    sudo apt install ca-certificates -y
fi

# Install caCopy the Eaton certificate and loadit
sudo cp $EATONCERTIFICATE_SECUREFILEPATH  /usr/local/share/ca-certificates/

# Update the certificate
sudo update-ca-certificates