#!/bin/bash

# Written by Maxence G. de Montauzan

# GLOBAL VARIABLES
# TODO Put in another files
readonly CONTAINER_NAME="sshd" # Name of the docker container
readonly IMG_NAME="mgdemontauzan/ssh" # Name of the docker image to run

#===  FUNCTION  ================================================================
# Launch a new docker container with a name.
# Parameter : name of the container
#===============================================================================
launch_new_container() {
	if [[ -z "$1" ]]; then
		echo "Function launch_new_container - Problem in script!" 1>2&
		exit 1
	fi

	echo ""
	echo "Run docker container"
	sudo docker run -d -p 22 --name $1 $IMG_NAME
}

#===  FUNCTION  ================================================================
# SSH connection to a container. Show IP, PORT and SSH command.
# Parameter : name of the container
#===============================================================================
connect_to_container() {
	if [[ -z "$1" ]]; then
		echo "Function connect_to_container - Problem in script!" 1>2&
		exit 1
	fi

	echo "Add SSH Key to connect with docker container"
	eval $(ssh-agent -s)
	ssh-add sshkey

	echo ""
	echo "Get port to connect to docker container"
	local port=$(sudo docker port $1 22 | awk -F ':' '{print $2}')
	echo "$port"

	echo ""
	echo "Get ip address of docker container"
	#ifconfig | grep docker -A 1 | awk '/[0-9]\./ {print $2}' | sed 's/adr://'
	local ipadress=$(ip addr show | grep docker \
		| awk '/[0-9]\./ {print $2}' \
		| sed 's/\/[0-9]*$//')
	echo $ipadress

	echo ""
	echo "Connecting to container:"
	echo "ssh root@$ipadress -p $port"
	echo ""
	ssh root@$ipadress -p $port
}

#===  FUNCTION  ================================================================
# Check if old containers exists and propose to delete it.
# Parameter 1: The name of the searched container.
# Return:
#	0 - Sucess
#	1 - Failure: container not deleted, can't launch a container
#===============================================================================
check_old_container() {
	if [[ -z "$1" ]]; then
		echo "Problem Function check_old_container - in script !!!" 1>2&
		exit 1
	fi

	if [[ -n $(sudo docker ps -a | cut -c141- | grep $1) ]]; then
		echo "Docker container SSHD history exists."
		read -r -p "Would you remove it ? [Y/n] " response
		if [[ $response =~ (^(yes|y)$|^$) ]]; then
			echo "Removing old sshd container..."
			sudo docker rm $1
			return 0
		else
			echo "Can't launch container - Conflict case" 1>2&
			return 1
		fi
	fi
}

# A container (or more) is already running
if [[ -n $(sudo docker ps | cut -c141- | grep $CONTAINER_NAME) ]]; then
	echo "Docker SSHD container already run."
	read -r -p "Would you stop it and launch a new container ? Reconnect to it ?
	 Keep it and launch another (and connect to it) ? [S/r/l/n]" response

	if [[ $response =~ (^(stop|s|S)$|^$) ]]; then
		./stopDeamon.sh
	elif [[ $response =~ (^(reconnect|reco|r|R)$) ]]; then
		echo "Reconnection to running container"
		if [[ $(sudo docker ps | cut -c141- | grep sshd | wc -l) -eq 1 ]]; then
			connect_to_container $(sudo docker ps | cut -c141- | grep sshd \
				| awk '{print $1}')
		else
			echo "Choose a running container to connect it :"
			sudo docker ps
			echo "Name ?"
			read name
			connect_to_container $name
		fi
		exit
	elif [[ $response =~ (^(launch|l|L)$) ]]; then
		echo "launch another container"
		nbContainer=$(sudo docker ps | cut -c141- | grep sshd | wc -l)
		nbContainer=$(expr $nbContainer + 1)
		containerName=sshd-$nbContainer
		check_old_container $containerName
		launch_new_container $containerName
		connect_to_container $containerName
		exit 0
	else
		echo "So don't run another deamon !"
		exit 0
	fi
else
	containerName=$CONTAINER_NAME # Name of the docker container
	check_old_container $containerName # Name of the docker image to run
	if [[ $? -eq 1 ]]; then
		echo ""
		echo "An old container exists - create another container"
		nbContainer=$(sudo docker ps -a | cut -c141- | grep sshd | wc -l)
		nbContainer=$(expr $nbContainer + 1)
		containerName=sshd-$nbContainer
	fi
	launch_new_container $containerName
	connect_to_container $containerName
fi
