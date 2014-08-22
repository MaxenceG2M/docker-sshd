#!/bin/bash

DEFAULT="sshd"
IMG_NAME="mgdemon/sshd"

launchNewContainer() {
	if [ -z "$1" ]
	then
		echo "Problem in script !!! (launchNewContainer)"
		exit
	fi

	echo ""
	echo "Run docker container"
	sudo docker run -d -p 22 --name $1 $IMG_NAME
}

connectToContainer() {
	if [ -z "$1" ]
	then
		echo "Problem in script !!! (connectToContainer)"
		exit
	fi

	echo "Add SSH Key to connect with docker container"
	eval `ssh-agent -s`
	ssh-add sshkey

	echo ""
	echo "Get port to connect to docker container"
	port=`sudo docker port $1 22 | awk -F ':' '{print $2}'`
	echo "$port"

	echo ""
	echo "Get ip address of docker container"
	#ifconfig | grep docker -A 1 | awk '/[0-9]\./ {print $2}' | sed 's/adr://'
	ipadress=`ip addr show | grep docker | awk '/[0-9]\./ {print $2}' | sed 's/\/[0-9]*$//'`
	echo $ipadress

	echo ""
	echo "Connecting to container:"
	echo "ssh root@$ipadress -p $port"
	echo ""
	ssh root@$ipadress -p $port
}

checkNoOldContainer() {
	if [ -z "$1" ]
	then
		echo "Problem in script !!! (checkNoOldContainer)"
		exit
	fi

	if [[ -n $(sudo docker ps -a | grep $1) ]]; then
		echo "Docker container SSHD history exists."
		read -r -p "Would you remove it ? [Y/n] " response
		if [[ $response =~ (^(yes|y)$|^$) ]]
		then
			echo "Removing old sshd container..."
			sudo docker rm $1
			return 0
		else
			echo "Can't launch container - Conflict case"
			return 1
		fi
	fi
}

# A container (or more) is already running
if [[ -n $(sudo docker ps | grep sshd) ]]; then
	echo "Docker SSHD container already run."
	read -r -p "Would you stop it and launch a new container ? Reconnect to it ? Keep it and launch another (and connect to it) ? [S/r/l/n]" response

	if [[ $response =~ (^(stop|s|S)$|^$) ]]
	then
		./stopDeamon.sh
	elif [[ $response =~ (^(reconnect|reco|r|R)$) ]]
	then
		echo "Reconnection to running container"
		if [[ $(sudo docker ps | grep sshd | wc -l) -eq 1 ]]
		then
			connectToContainer $(sudo docker ps | grep sshd | awk '{print $1}')
		else
			echo "Choose a running container to connect it :"
			sudo docker ps 
			echo "Name ?"
			read name
			connectToContainer $name
		fi
		exit
	elif [[ $response =~ (^(launch|l|L)$) ]]
	then
		echo "launch another container"
		nbContainer=`sudo docker ps | grep sshd | wc -l`
		nbContainer=`expr $nbContainer + 1`
		containerName=sshd-$nbContainer
		checkNoOldContainer $containerName
		launchNewContainer $containerName
		connectToContainer $containerName
		exit
	else 
		echo "So don't run another deamon !"
		exit
	fi
else
	containerName=$DEFAULT
	checkNoOldContainer $containerName
	if [[ $? -eq 1 ]]
	then
		echo ""
		echo "An old container exists - create another container"
		nbContainer=`sudo docker ps -a | grep sshd | wc -l`
		nbContainer=`expr $nbContainer + 1`
		containerName=sshd-$nbContainer
	fi
	launchNewContainer $containerName
	connectToContainer $containerName
fi
