# Activate command print
set -o xtrace

# Create the application directories
sudo lxc-attach -n $(ContainerName) -- bash -c '
    set -o xtrace
    if [ ! -d "$(ContainerDataAgentDirectory)/bin" ]; then 
        install -o $(ContainerPXMC3000Username) -g $(ContainerPXMC3000Username)  -d $(ContainerDataAgentDirectory)/bin 
    fi
    if [ ! -d "$(ContainerDataAgentDirectory)/log" ]; then 
        install -o $(ContainerPXMC3000Username) -g $(ContainerPXMC3000Username)  -d $(ContainerDataAgentDirectory)/log 
    fi
    if [ ! -d "$(ContainerWebClientDirectory)" ]; then 
        install -o $(ContainerPXMC3000Username) -g $(ContainerPXMC3000Username)  -d $(ContainerWebClientDirectory)
    fi
    if [ ! -d "$(ContainerWebServerDirectory)" ]; then 
        install -o $(ContainerPXMC3000Username) -g $(ContainerPXMC3000Username)  -d $(ContainerWebServerDirectory) 
    fi
    if [ ! -d "$(ContainerDatabaseDirectory)" ]; then 
        install -o $(ContainerPXMC3000Username) -g $(ContainerPXMC3000Username)  -d $(ContainerDatabaseDirectory) 
    fi
    if [ ! -d "$(ContainerCertificateDirectory)" ]; then 
        install -o $(ContainerPXMC3000Username) -g $(ContainerPXMC3000Username)  -d $(ContainerCertificateDirectory)
    fi'


#  Copy PXMC3000-data-agent files
cp -R $(System.ArtifactsDirectory)/PXMC3000-data-agent/PXMC3000-data-agent  /proc/$(sudo lxc-info -n $(ContainerName) -p -H)/root/$(ContainerDataAgentDirectory)/PXMC3000-data-agent
# Copy PXMC3000-web-server files
cp -R $(System.ArtifactsDirectory)/PXMC3000-web-server/PXMC3000-web-server.js  /proc/$(sudo lxc-info -n $(ContainerName) -p -H)/root/$(ContainerWebServerDirectory)/PXMC3000-web-server.js
# Copy PXMC3000-web-client files
cp -R $(System.ArtifactsDirectory)/PXMC3000-web-client/PXMC3000-web-client/.  /proc/$(sudo lxc-info -n $(ContainerName) -p -H)/root/$(ContainerWebClientDirectory)


 # Set permission

 sudo lxc-attach -n $(ContainerName) -- bash -c '
    set -o xtrace
    chown -R $(ContainerPXMC3000Username):$(ContainerPXMC3000Username) $(ContainerPXMC3000HomeFolder)
    chmod -R 744 $(ContainerPXMC3000HomeFolder)'