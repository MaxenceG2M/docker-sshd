FROM dockerfile/ubuntu

# Install openssh-server
RUN apt-get update
RUN apt-get install -qqy openssh-server

# Fix PAM login issu
RUN sed -i 's/session    required     pam_loginuid.so/session    optional     pam_loginuid.so/g' /etc/pam.d/sshd

RUN mkdir /var/run/sshd && chmod 0755 /var/run/sshd/

RUN mkdir /root/.ssh/
ADD sshkey.pub /root/.ssh/authorized_keys

#X11 Apps
RUN apt-get install -qqy x11-apps

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
