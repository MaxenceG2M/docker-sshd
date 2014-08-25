#!/bin/bash

# Written by Maxence G. de Montauzan

# GLOBAL VARIABLES
# TODO Put in another files
readonly CONTAINER_NAME="sshd" # Name of the docker container
readonly IMG_NAME="mgdemontauzan/sshd" # Name of the docker image to run

#===  FUNCTION  ================================================================
# Launch a new docker container with a name.
# Parameter : name of the container
#===============================================================================
launch_new_container() {
	if [[ -z "$1" ]]; then
		echo "Function launch_new_container - Problem in script!" 1>2&
		exit 1
	else
		echo "Function launch_new_container - Problem in script!" 1>2&
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

#===  MAIN  ====================================================================
# Var for main
docker_ps=$(sudo docker ps | cut -c141- | grep $CONTAINER_NAME)
nb_container=$(echo "$docker_ps" | wc -l)

# If a container is already running
if [[ -n $docker_ps ]]; then
	echo "Docker SSHD container already run."
	echo "What do you want to do?"
	echo "[R] Reconnect to this conainter"
	echo "[s] Stop it and launch another container"
	echo "   (if you want just stop it, run \"stopDeamon.sh\""
	echo "[k] Keep it running and launch another container"
	echo "[n] Do nothing."
	read -r -p "Time to choose... [R/s/k/n] " response

	if [[ $response =~ (^(stop|s|S|STOP)$) ]]; then
		./stopDeamon.sh
	elif [[ $response =~ (^(keep|k|K|KEEP)$) ]]; then
		echo "Launch another container"
		nb_container=$(expr $nb_container + 1)
		container_name=sshd-$nb_container
		check_old_container $container_name
		launch_new_container $container_name
		connect_to_container $container_name
		exit 0
	elif [[ $response =~ (^(n|no|nothing|N|NO|NOTHING)$) ]]; then
		echo "So don't run me!"
		exit 0
	else
		echo ""
		echo "Reconnection to a running container..."
		echo ""
		echo $docker_ps
		echo $nb_container
		# Check if only one container run
		if [[ $nb_container -eq 1 ]]; then
			connect_to_container $docker_ps
		else
			echo "Docker container running:"
			echo "$docker_ps"
			read -r -p "Choose a container: " name
			if [[ $docker_ps =~ $name ]]; then
				connect_to_container $name
			else
				echo "Container doesn't exist."
				exit 1
			fi
		fi
		exit
	fi
else
	container_name=$CONTAINER_NAME # Name of the docker container
	check_old_container $container_name # Name of the docker image to run
	if [[ $? -eq 1 ]]; then
		echo ""
		echo "An old container exists - create another container"
		nb_container=$(sudo docker ps -a | cut -c141- | grep sshd | wc -l)
		nb_container=$(expr $nb_container + 1)
		container_name=sshd-$nb_container
	fi
	launch_new_container $container_name
	connect_to_container $container_name
fi
