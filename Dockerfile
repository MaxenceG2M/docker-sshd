FROM dockerfile/ubuntu
MAINTAINER Maxence G. de Montauzan <MGermaindeMontauzan@voyages-sncf.com>

# Install openssh-server
RUN apt-get update && apt-get install -qqy openssh-server

# Fix PAM login issu
RUN sed -i 's/session    required     pam_loginuid.so/session    optional     pam_loginuid.so/g' /etc/pam.d/sshd

RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd/

# Conf sshd for root login
RUN cp /etc/ssh/sshd_config /etc/ssh/sshd_config.factory-defaults && \
	chmod a-w /etc/ssh/sshd_config.factory-defaults
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN echo 'root:root' | chpasswd

# Install some tools
RUN apt-get install -qqy x11-apps
RUN apt-get install -qqy openjdk-7-jdk

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
