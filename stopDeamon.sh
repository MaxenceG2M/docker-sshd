#!/bin/bash

# Written by Maxence G. de Montauzan

readonly CONTAINER_NAME="sshd" # Name of the docker container
readonly IMG_NAME="mgdemontauzan/sshd" # Name of the docker image to run

sudo docker stop $CONTAINER_NAME
echo "Deamon was stopped"

if [[ -n $(sudo docker ps -a | grep $CONTAINER_NAME) ]]; then
	echo ""
	echo "An old docker container SSHD exists."
	read -r -p "Would you remove it ? [Y/n] " response
	if [[ $response =~ (^(yes|y)$|^$) ]]; then
		echo "Removing old sshd container..."
		sudo docker rm $CONTAINER_NAME
	fi
fi
