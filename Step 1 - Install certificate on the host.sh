# Activate command print
set -o xtrace

# Install updates & upgrades
apt update -y
apt upgrade -y

# Check if sudo lib is installed, if not, install it
if [[ ! $(dpkg -l ca-certificates | grep ii 2>/dev/null) ]]; then
    sudo apt install ca-certificates -y
fi

# Install caCopy the Eaton certificate and loadit
sudo cp $EATONCERTIFICATE_SECUREFILEPATH  /usr/local/share/ca-certificates/

# Update the certificate
sudo update-ca-certificates