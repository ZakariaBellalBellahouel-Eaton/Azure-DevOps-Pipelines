# Activate command print
set -o xtrace

# Add proxy configuration 
export no_proxy=localhost, 127.0.0.1
export https_proxy=http://proxy.etn.com:8080
export http_proxy=http://proxy.etn.com:8080

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
        install -o $CONTAINERPXMC3000USERNAME -g $CONTAINERPXMC3000USERNAME  -d $CONTAINERDATABASEDIRECTORY
    fi
    if [ ! -d \"$CONTAINERCERTIFICATEDIRECTORY\" ]; then
        install -o $CONTAINERPXMC3000USERNAME -g $CONTAINERPXMC3000USERNAME  -d $CONTAINERCERTIFICATEDIRECTORY
    fi"


#  Copy PXMC3000-data-agent files
cp $SYSTEM_ARTIFACTSDIRECTORY/pxmc3000-artifacts/pxmc3000-data-agent/PXMC3000-data-agent  /proc/$(sudo lxc-info -n $CONTAINERNAME -p -H)/root/$CONTAINERDATAAGENTDIRECTORY/bin/$CONTAINERPXMC3000DATAAGENTSERVICENAME
# Copy PXMC3000-web-server files
cp $SYSTEM_ARTIFACTSDIRECTORY/pxmc3000-artifacts/pxmc3000-web-server/PXMC3000-web-server.js  /proc/$(sudo lxc-info -n $CONTAINERNAME -p -H)/root/$CONTAINERWEBSERVERDIRECTORY/$CONTAINERPXMC3000WEBSERVERSERVICENAME.js
# Copy PXMC3000-web-client files
cp -R $SYSTEM_ARTIFACTSDIRECTORY/pxmc3000-artifacts/pxmc3000-web-client/PXMC3000-web-client/.  /proc/$(sudo lxc-info -n $CONTAINERNAME -p -H)/root/$CONTAINERWEBCLIENTDIRECTORY


# Set permission

sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    set -o xtrace
    chown -R $CONTAINERPXMC3000USERNAME:$CONTAINERPXMC3000USERNAME $CONTAINERPXMC3000HOMEFOLDER
    chmod -R 744 $CONTAINERPXMC3000HOMEFOLDER"