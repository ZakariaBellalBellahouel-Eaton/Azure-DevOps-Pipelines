# Activate command print
set -o xtrace

# Install the PXMC3000 data agent service
#Check if the service is running, if so stop it.
sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    if [[ $(systemctl is-active  $CONTAINERPXMC3000DATAAGENTSERVICENAME | grep -w active) ]]; then
        systemctl stop $CONTAINERPXMC3000DATAAGENTSERVICENAME
fi"

sudo lxc-attach -n $CONTAINERNAME -- bash -c "
#Create the service $CONTAINERPXMC3000DATAAGENTSERVICENAME
echo \"[Unit]\" > /etc/systemd/system/$CONTAINERPXMC3000DATAAGENTSERVICENAME.service
echo \"Description=Smp Rest API Client that runs in regular interval to retrieve the data and save it in database.\" >> /etc/systemd/system/$CONTAINERPXMC3000DATAAGENTSERVICENAME.service
echo \"\"  >>  /etc/systemd/system/$CONTAINERPXMC3000DATAAGENTSERVICENAME.service
echo \"[Install]\" >>  /etc/systemd/system/$CONTAINERPXMC3000DATAAGENTSERVICENAME.service
echo \"WantedBy=multi-user.target\" >>  /etc/systemd/system/$CONTAINERPXMC3000DATAAGENTSERVICENAME.service
echo \"Alias=SmpDataAgent.service\" >>  /etc/systemd/system/$CONTAINERPXMC3000DATAAGENTSERVICENAME.service
echo \"\" >>  /etc/systemd/system/$CONTAINERPXMC3000DATAAGENTSERVICENAME.service
echo \"[Service]\" >>  /etc/systemd/system/$CONTAINERPXMC3000DATAAGENTSERVICENAME.service
echo \"Type=simple\" >>  /etc/systemd/system/$CONTAINERPXMC3000DATAAGENTSERVICENAME.service
echo \"ExecStart=$CONTAINERDATAAGENTDIRECTORY/bin/SmpDataAgent\" >>  /etc/systemd/system/$CONTAINERPXMC3000DATAAGENTSERVICENAME.service
echo \"WorkingDirectory=$CONTAINERDATAAGENTDIRECTORY\" >>  /etc/systemd/system/$CONTAINERPXMC3000DATAAGENTSERVICENAME.service
echo \"#StandardOutput=syslog\" >>  /etc/systemd/system/$CONTAINERPXMC3000DATAAGENTSERVICENAME.service
echo \"#StandardError=syslog\" >>  /etc/systemd/system/$CONTAINERPXMC3000DATAAGENTSERVICENAME.service
echo \"SyslogIdentifier=SmpDataAgent\" >>  /etc/systemd/system/$CONTAINERPXMC3000DATAAGENTSERVICENAME.service"

# Enable and start the service
sudo lxc-attach -n $CONTAINERNAME -- bash -c "
# Enable the service
systemctl enable $CONTAINERPXMC3000DATAAGENTSERVICENAME.service
# Start the service
systemctl start $CONTAINERPXMC3000DATAAGENTSERVICENAME.service"

# Install the PXMC3000 web server service
#Check if the service is running, if so stop it.

#Check if the service is running, if so stop it.
sudo lxc-attach -n $CONTAINERNAME -- bash -c "
    if [[ $(systemctl is-active  $CONTAINERPXMC3000WEBSERVERSERVICENAME | grep -w active) ]]; then
        systemctl stop $CONTAINERPXMC3000WEBSERVERSERVICENAME
    fi"

sudo lxc-attach -n $CONTAINERNAME -- bash -c "
#Create the service $CONTAINERPXMC3000WEBSERVERSERVICENAME
echo \"[Unit]\" > /etc/systemd/system/$CONTAINERPXMC3000WEBSERVERSERVICENAME.service
echo \"Description=Smp Rest API Client that runs in regular interval to retrieve the data and save it in database.\" >> /etc/systemd/system/$CONTAINERPXMC3000WEBSERVERSERVICENAME.service
echo \"\"  >>  /etc/systemd/system/$CONTAINERPXMC3000WEBSERVERSERVICENAME.service
echo \"[Install]\" >>  /etc/systemd/system/$CONTAINERPXMC3000WEBSERVERSERVICENAME.service
echo \"WantedBy=multi-user.target\" >>  /etc/systemd/system/$CONTAINERPXMC3000WEBSERVERSERVICENAME.service
echo \"Alias=SmpDataAgent.service\" >>  /etc/systemd/system/$CONTAINERPXMC3000WEBSERVERSERVICENAME.service
echo \"\" >>  /etc/systemd/system/$CONTAINERPXMC3000WEBSERVERSERVICENAME.service
echo \"[Service]\" >>  /etc/systemd/system/$CONTAINERPXMC3000WEBSERVERSERVICENAME.service
echo \"Type=simple\" >>  /etc/systemd/system/$CONTAINERPXMC3000WEBSERVERSERVICENAME.service
echo \"ExecStart=$CONTAINERWEBSERVERDIRECTORY/bin/SmpDataAgent\" >>  /etc/systemd/system/$CONTAINERPXMC3000WEBSERVERSERVICENAME.service
echo \"WorkingDirectory=$CONTAINERWEBSERVERDIRECTORY\" >>  /etc/systemd/system/$CONTAINERPXMC3000WEBSERVERSERVICENAME.service
echo \"#StandardOutput=syslog\" >>  /etc/systemd/system/$CONTAINERPXMC3000WEBSERVERSERVICENAME.service
echo \"#StandardError=syslog\" >>  /etc/systemd/system/$CONTAINERPXMC3000WEBSERVERSERVICENAME.service
echo \"SyslogIdentifier=SmpDataAgent\" >>  /etc/systemd/system/$CONTAINERPXMC3000WEBSERVERSERVICENAME.service"

# Enable and start the service
sudo lxc-attach -n $CONTAINERNAME -- bash -c "
# Enable the service
systemctl enable $CONTAINERPXMC3000WEBSERVERSERVICENAME.service
# Start the service
systemctl start $CONTAINERPXMC3000WEBSERVERSERVICENAME.service"