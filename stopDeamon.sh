#!/bin/bash

sudo docker stop sshd
echo "Deamon was stopped"

if [[ -n $(sudo docker ps -a | grep sshd) ]]; then
	echo ""
	echo "An old docker container SSHD exists."
	read -r -p "Would you remove it ? [Y/n] " response
	if [[ $response =~ (^(yes|y)$|^$) ]]
	then
		echo "Removing old sshd container..."
		sudo docker rm sshd
	fi
fi
