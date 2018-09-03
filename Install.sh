#!/bin/bash -e

# version 0.1
# Haim Cohen 2018


# Set Zabbix Server below:
ZABBIX_SERVER_IP=111.222.333.444


if [ "$UID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

### Only run it if we can (ie. on Ubuntu/Debian)

if [ -x /usr/bin/apt-get ]; then
  apt-get update
  apt-get -y install zabbix-agent 
  systemctl enable zabbix-agent
  sed -i "s/Server=127.0.0.1/Server=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
  sed -i "s/ServerActive=127.0.0.1/ServerActive=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
  HOSTNAME=`hostname` && sed -i "s/Hostname=Zabbix\ server/Hostname=$HOSTNAME/" /etc/zabbix/zabbix_agentd.conf
  ufw allow 10050/tcp
  systemctl restart zabbix-agent 
fi
  
### Only run it if we can (ie. on CentOS/RHEL)
if [ -x /usr/bin/yum ]; then
  yum -y update
  rpm -ivh http://repo.zabbix.com/zabbix/2.4/rhel/6/x86_64/zabbix-release-2.4-1.el6.noarch.rpm
  yum -y install zabbix-agent
  chkconfig zabbix-agent on
  sed -i "s/Server=127.0.0.1/Server=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
  sed -i "s/ServerActive=127.0.0.1/ServerActive=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
  HOSTNAME=`hostname` && sed -i "s/Hostname=Zabbix\ server/Hostname=$HOSTNAME/" /etc/zabbix/zabbix_agentd.conf
  firewall-cmd --add-port=10050/tcp --permanent 
  firewall-cmd --reload
  service zabbix-agent restart
fi

### Only run it if we can (ie. on openSuse/SLES)
if [ -x /usr/bin/zypper ]; then
  zypper addrepo http://download.opensuse.org/repositories/server:/monitoring/SLE_11_SP3/ server_monitoring
  zypper update
  zypper install zabbix-agent
  sed -i "s/Server=127.0.0.1/Server=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
  sed -i "s/ServerActive=127.0.0.1/ServerActive=${ZABBIX_SERVER_IP}/" /etc/zabbix/zabbix_agentd.conf
  HOSTNAME=`hostname` && sed -i "s/Hostname=Zabbix\ server/Hostname=$HOSTNAME/" /etc/zabbix/zabbix_agentd.conf
  rczabbix-agentd start
  chkconfig --set zabbix-agentd on
