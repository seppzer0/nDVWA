#!/bin/bash

IP="172.17.0.1"


# start services
service mariadb start
service php8.3-fpm start
service nginx start
sleep 1

# prompt to either proceed with SSH configurations or jump into shell
printf "\n\n"
read -p "[ ? ] Proceed with SSH configurations? [yes/no] " yn
case $yn in
  yes )
      # Step: Establishing Reverse Tunneling to SSH
      printf "\n\n== Establishing Reverse Tunneling to SSH ==\n"
      # ask for host's credentials, which will be required for sudo operations
      printf "\n[ * ] Please enter the following information from you host environment.\n"
      read -p "    - Username: " USER
      read -s -p "    - Password: " PASS
      printf "\n"
      # setup container's SSH keys and connection to the SSH server (host environment)
      printf "\n[ * ] Setting up SSH keys.\n\n"
      ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/id_rsa
      sshpass -p ${PASS} ssh-copy-id -o StrictHostKeyChecking=no ${USER}@${IP}
      printf "\n[ * ] Configuring reverse tunneling.\n\n"
      ssh -f -N -R 2222:localhost:22 ${USER}@${IP}
      printf "[ * ] Opening SSH connection. When ready, \"exit\" it to proceed with port knocking protection setup.\n\n"
      ssh -p 22 ${USER}@${IP}

      # Step: Protecting SSH from Nmap Scanning (port knocking protection)
      printf "\n\n== Protecting SSH from Nmap Scanning ==\n"
      printf "\n[ * ] Please enter the following information from you host environment.\n"
      read -p "    - Full path to this repository: " RPATH
      printf "\n"
      printf "\n[ * ] Checking that SSH port is currently open using NMAP.\n\n"
      nmap -p 22 172.17.0.1
      printf "\n[ * ] Configuring knockd service on the host machine (via SSH).\n\n"
      ssh -p 22 ${USER}@${IP} -t "cd ${RPATH} && echo ${PASS} | sudo -S bash knockd_setup.sh"
      sleep 1
      printf "\n[ * ] Attemting to scan the SSH port and connect to the SSH server with knockd service running.\n\n"
      nmap -p 22 172.17.0.1
      ssh -p 22 ${USER}@${IP}
      printf "\n[ * ] Executing magic knock-knock sequence and actually connecting to the SSH server. When ready, \"exit\" it to proceed.\n\n"
      knock -v 172.17.0.1 20001 20002 20003 -d 500
      ssh -p 22 ${USER}@${IP}
      printf "\n[ * ] Restoring iptables rules on the host machine.\n\n"
      knock -v 172.17.0.1 20001 20002 20003 -d 500
      ssh -p 22 ${USER}@${IP} -t "echo ${PASS} | sudo -S iptables -F DOCKER && sudo -S iptables -F INPUT && sudo -S service knockd stop"
      ;;
  no )
     printf "[ * ] Jumping directly into Bash shell..\n\n";;
  * ) printf "\n[ ! ] Error: Invalid response, exiting container..\n\n";
    exit 1;;
esac

# start a shell to freeroam in the container
/bin/bash
