FROM dockerfile/ubuntu
MAINTAINER Maxence G. de Montauzan <MGermaindeMontauzan@voyages-sncf.com>

# Install openssh-server
RUN apt-get update && apt-get install -qqy openssh-server

# Fix PAM login issu
RUN sed -i 's/session    required     pam_loginuid.so/session    optional     pam_loginuid.so/g' /etc/pam.d/sshd

RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd/

RUN mkdir /root/.ssh/
ADD sshkey.pub /root/.ssh/authorized_keys

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
