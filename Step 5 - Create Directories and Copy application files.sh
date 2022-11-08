# Activate command print
set -o xtrace

# Create the application directories
sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    set -o xtrace
    if [ ! -d \"$CONTAINERDATAAGENTDIRECTORY/bin\" ]; then
        install -o $CONTAINERPXMC3000USERNAME -g $CONTAINERPXMC3000USERNAME  -d $CONTAINERDATAAGENTDIRECTORY/bin
    fi
    if [ ! -d \"$CONTAINERDATAAGENTDIRECTORY/log\" ]; then
        install -o $CONTAINERPXMC3000USERNAME -g $CONTAINERPXMC3000USERNAME  -d $CONTAINERDATAAGENTDIRECTORY/log
    fi
    if [ ! -d \"$CONTAINERWEBCLIENTDIRECTORY\" ]; then
        install -o $CONTAINERPXMC3000USERNAME -g $CONTAINERPXMC3000USERNAME  -d $CONTAINERWEBCLIENTDIRECTORY
    fi
    if [ ! -d \"$CONTAINERWEBSERVERDIRECTORY\" ]; then
        install -o $CONTAINERPXMC3000USERNAME -g $CONTAINERPXMC3000USERNAME  -d $CONTAINERWEBSERVERDIRECTORY
    fi
    if [ ! -d \"$CONTAINERDATABASEDIRECTORY\" ]; then
        install -o $ContainerPXMC3000Username -g $CONTAINERPXMC3000USERNAME  -d $CONTAINERDATABASEDIRECTORY
    fi
    if [ ! -d \"$CONTAINERCERTIFICATEDIRECTORY\" ]; then
        install -o $CONTAINERPXMC3000USERNAME -g $CONTAINERPXMC3000USERNAME  -d $CONTAINERCERTIFICATEDIRECTORY
    fi"


#  Copy PXMC3000-data-agent files
cp -R $(System.ArtifactsDirectory)/PXMC3000-data-agent/PXMC3000-data-agent  /proc/$(sudo lxc-info -n $CONTAINERNAME -p -H)/root/$CONTAINERDATAAGENTDIRECTORY/PXMC3000-data-agent
# Copy PXMC3000-web-server files
cp -R $(System.ArtifactsDirectory)/PXMC3000-web-server/PXMC3000-web-server.js  /proc/$(sudo lxc-info -n $CONTAINERNAME -p -H)/root/$CONTAINERWEBSERVERDIRECTORY/PXMC3000-web-server.js
# Copy PXMC3000-web-client files
cp -R $(System.ArtifactsDirectory)/PXMC3000-web-client/PXMC3000-web-client/.  /proc/$(sudo lxc-info -n $CONTAINERNAME -p -H)/root/$CONTAINERWEBCLIENTDIRECTORY


# Set permission

sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    set -o xtrace
    chown -R $CONTAINERPXMC3000USERNAME:$CONTAINERPXMC3000USERNAME $CONTAINERPXMC3000HOMEFOLDER
    chmod -R 744 $CONTAINERPXMC3000HOMEFOLDER"