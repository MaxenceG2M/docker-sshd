Docker SHH Container
======

This is a docker container allowing SSH connection.

To build:

    sudo docker build -t mgdemontauzan/sshd .


Dockerfile describe image. 
Add an sshkey file to allow connection by private key (no password needed).

## Scripts

- `launchDeamon.sh` : start a container and connect to it, manage if a container is already running (proposes to reconnect, launch a new container, etc.)

- `stopDeamon.sh` : stop a container.

Run on CentOS.

## TODO
- Separate methods in `launchDeamon.sh` in more little scripts
- Documentation ! More comments !

