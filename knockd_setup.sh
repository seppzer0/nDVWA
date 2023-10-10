#!/bin/bash

# install and configure knockd
apt-get update && apt-get install -y knockd
cat >/etc/knockd.conf <<EOL
[options]
        UseSyslog

[openSSH]
        sequence    = 20001,20002,20003
        seq_timeout = 10
        command     = /sbin/iptables -I INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
        tcpflags    = syn

[closeSSH]
        sequence    = 20003,20002,20001
        seq_timeout = 10
        command     = /sbin/iptables -D INPUT -s %IP% -p tcp --dport 22 -j ACCEPT
        tcpflags    = syn
EOL
# configure knockd to listen on specific network interface
cat >/etc/default/knockd <<EOL
# control if we start knockd at init or not# 1 = start
# anything else = don't start
# PLEASE EDIT /etc/knockd.conf BEFORE ENABLING
START_KNOCKD=1

# command line options
KNOCKD_OPTS="-i docker0"
EOL
# start the service
service knockd restart
# block 22 port of firewall via iptables rules
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -p tcp --dport 22 -j REJECT
