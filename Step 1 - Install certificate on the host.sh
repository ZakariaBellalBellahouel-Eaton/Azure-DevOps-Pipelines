# Activate command print
set -o xtrace

# Add proxy configuration 
sudo echo "export no_proxy=localhost, 127.0.0.1" > /etc/environment
sudo echo "export https_proxy=http://proxy.etn.com:8080" >> /etc/environment
sudo echo "export http_proxy=http://proxy.etn.com:8080" >> /etc/environment

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