
FROM ubuntu:latest

MAINTAINER <dockerfile@mjbright.net> Mike Bright

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y openssh-server whois sudo

#RUN useradd user --uid 1001 --password $(mkpasswd password) --home /home/user --create-home --gid users --groups users
RUN useradd user --uid 1001 --home /home/user --create-home --gid users --groups users

RUN [ ! -d /home/user/.ssh ] && mkdir /home/user/.ssh
ADD authorized_keys /home/user/.ssh/authorized_keys

RUN chmod 500 /home/user/.ssh
RUN chmod 400 /home/user/.ssh/authorized_keys
RUN chown -R user:users /home/user/.ssh
RUN echo PasswordAuthentication no >> /etc/ssh/sshd_config
RUN passwd -u user

ADD start_ssh_incontainer.sh /

#RUN echo "user    ALL=(ALL:ALL) NOPASSWD:ALL" | tee -a /etc/sudoers
RUN echo "user    ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers

