# Activate command print
set -o xtrace

# Install the PXMC3000 data agent service
#Check if the service is running, if so stop it.
sudo lxc-attach -n $(ContainerName) -- bash -c '
    if [[ $(systemctl is-active  $(ContainerPXMC3000DataAgentServiceName) | grep -w active) ]]; then
        systemctl stop $(ContainerPXMC3000DataAgentServiceName)
    fi'

sudo lxc-attach -n $(ContainerName) -- bash -c '
#Create the service $(ContainerPXMC3000DataAgentServiceName)
echo "[Unit]" > /etc/systemd/system/$(ContainerPXMC3000DataAgentServiceName).service
echo "Description=Smp Rest API Client that runs in regular interval to retrieve the data and save it in database." >> /etc/systemd/system/$(ContainerPXMC3000DataAgentServiceName).service
echo ""  >>  /etc/systemd/system/$(ContainerPXMC3000DataAgentServiceName).service
echo "[Install]" >>  /etc/systemd/system/$(ContainerPXMC3000DataAgentServiceName).service
echo "WantedBy=multi-user.target" >>  /etc/systemd/system/$(ContainerPXMC3000DataAgentServiceName).service
echo "Alias=SmpDataAgent.service" >>  /etc/systemd/system/$(ContainerPXMC3000DataAgentServiceName).service
echo "" >>  /etc/systemd/system/$(ContainerPXMC3000DataAgentServiceName).service
echo "[Service]" >>  /etc/systemd/system/$(ContainerPXMC3000DataAgentServiceName).service
echo "Type=simple" >>  /etc/systemd/system/$(ContainerPXMC3000DataAgentServiceName).service
echo "ExecStart=$(ContainerDataAgentDirectory)/bin/SmpDataAgent" >>  /etc/systemd/system/$(ContainerPXMC3000DataAgentServiceName).service
echo "WorkingDirectory=$(ContainerDataAgentDirectory)" >>  /etc/systemd/system/$(ContainerPXMC3000DataAgentServiceName).service
echo "#StandardOutput=syslog" >>  /etc/systemd/system/$(ContainerPXMC3000DataAgentServiceName).service
echo "#StandardError=syslog" >>  /etc/systemd/system/$(ContainerPXMC3000DataAgentServiceName).service
echo "SyslogIdentifier=SmpDataAgent" >>  /etc/systemd/system/$(ContainerPXMC3000DataAgentServiceName).service'

# Enable and start the service
sudo lxc-attach -n SmpApplication -- bash -c '
# Enable the service
systemctl enable $(ContainerPXMC3000DataAgentServiceName).service 
# Start the service
systemctl start $(ContainerPXMC3000DataAgentServiceName).service'

# Install the PXMC3000 web server service
#Check if the service is running, if so stop it.

#Check if the service is running, if so stop it.
sudo lxc-attach -n $(ContainerName) -- bash -c '
    if [[ $(systemctl is-active  $(ContainerPXMC3000WebServerServiceName) | grep -w active) ]]; then
        systemctl stop $(ContainerPXMC3000WebServerServiceName)
    fi'

sudo lxc-attach -n $(ContainerName) -- bash -c '
#Create the service $(ContainerPXMC3000WebServerServiceName)
echo "[Unit]" > /etc/systemd/system/$(ContainerPXMC3000WebServerServiceName).service
echo "Description=Smp Rest API Client that runs in regular interval to retrieve the data and save it in database." >> /etc/systemd/system/$(ContainerPXMC3000WebServerServiceName).service
echo ""  >>  /etc/systemd/system/$(ContainerPXMC3000WebServerServiceName).service
echo "[Install]" >>  /etc/systemd/system/$(ContainerPXMC3000WebServerServiceName).service
echo "WantedBy=multi-user.target" >>  /etc/systemd/system/$(ContainerPXMC3000WebServerServiceName).service
echo "Alias=SmpDataAgent.service" >>  /etc/systemd/system/$(ContainerPXMC3000WebServerServiceName).service
echo "" >>  /etc/systemd/system/$(ContainerPXMC3000WebServerServiceName).service
echo "[Service]" >>  /etc/systemd/system/$(ContainerPXMC3000WebServerServiceName).service
echo "Type=simple" >>  /etc/systemd/system/$(ContainerPXMC3000WebServerServiceName).service
echo "ExecStart=$(ContainerWebServerDirectory)/bin/SmpDataAgent" >>  /etc/systemd/system/$(ContainerPXMC3000WebServerServiceName).service
echo "WorkingDirectory=$(ContainerWebServerDirectory)" >>  /etc/systemd/system/$(ContainerPXMC3000WebServerServiceName).service
echo "#StandardOutput=syslog" >>  /etc/systemd/system/$(ContainerPXMC3000WebServerServiceName).service
echo "#StandardError=syslog" >>  /etc/systemd/system/$(ContainerPXMC3000WebServerServiceName).service
echo "SyslogIdentifier=SmpDataAgent" >>  /etc/systemd/system/$(ContainerPXMC3000WebServerServiceName).service'

# Enable and start the service
sudo lxc-attach -n SmpApplication -- bash -c '
# Enable the service
systemctl enable $(ContainerPXMC3000WebServerServiceName).service 
# Start the service
systemctl start $(ContainerPXMC3000WebServerServiceName).service'