#!/bin/bash

if [[ -n $(sudo docker ps | grep sshd) ]]; then
	echo "Docker SSHD container already run."
	read -r -p "Would you stop it ? [Y/n]" response
	if [[ $response =~ (^(yes|y)$|^$) ]]
	then
		./stopDeamon.sh
	else
		"So don't run another deamon !"
		# Todo : run another deamon !
		exit
	fi
fi

if [[ -n $(sudo docker ps -a | grep sshd) ]]; then
	echo "Docker container SSHD history exists."
	read -r -p "Would you remove it ? [Y/n] " response
	if [[ $response =~ (^(yes|y)$|^$) ]]
	then
		echo "Removing old sshd container..."
		sudo docker rm sshd
	else
		echo "Can't launch - Conflict case. Game over."
		exit
	fi
fi

echo "Add SSH Key to connect with docker container"
eval `ssh-agent -s`
ssh-add sshkey

echo ""
echo "Run docker container"
sudo docker run -d -p 22 --name sshd mgdemon/sshd

echo ""
echo "Get port to connect to docker container"
port=`sudo docker port sshd 22 | awk -F ':' '{print $2}'`
echo "$port"

echo ""
echo "Get ip address of docker container"
#ifconfig | grep docker -A 1 | awk '/[0-9]\./ {print $2}' | sed 's/adr://'
ipadress=`ip addr show | grep docker | awk '/[0-9]\./ {print $2}' | sed 's/\/[0-9]*$//'`
echo $ipadress

echo ""
echo "Connecting to container:"
echo "ssh root@$ipadress -p $port"
ssh root@$ipadress -p $port
