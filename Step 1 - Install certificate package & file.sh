# Activate command print
set -o xtrace

echo "$[ContainerName] : "
echo $[ContainerName]
echo "$(ContainerName) : "
echo $(ContainerName)
echo "$[ContainerName] : "
echo ${{ContainerName}}

# Check if sudo lib is installed, if not, install it
sudo lxc-attach -n ${{ContainerName}} -- bash -c '
    set -o xtrace
    if [  ! $(dpkg -l | grep ca-certificates | grep ii 2>/dev/null) ]; then
        sudo apt update -y
        sudo apt install ca-certificates -y
    fi'

# Install caCopy the Eaton certificate and loadit
sudo cp $(EatonCertificate.secureFilePath)  /proc/$(sudo lxc-info -n ${{ContainerName}} -p -H)/root/usr/local/share/ca-certificates/
sudo cp $(EatonCertificate.secureFilePath)  /proc/$(sudo lxc-info -n ${{ContainerName}} -p -H)/root/$(ContainerCertificateDirectory)
sudo lxc-attach -n $(ContainerName) -- bash -c '
    set -o xtrace
    update-ca-certificates'