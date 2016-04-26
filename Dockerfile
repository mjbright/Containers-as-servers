
FROM ubuntu:latest

MAINTAINER <dockerfile@mjbright.net> Mike Bright

RUN apt-get update && apt-get upgrade -y

RUN apt-get install -y openssh-server whois sudo

#ENV PASSWORD=$(mkpasswd weak)
#RUN echo $PASSWORD
#RUN PASSWORD=$(mkpasswd weak)
#RUN echo $PASSWORD

#RUN sudo useradd user --uid 1001 --password $(mkpasswd password) --home /home/user --create-home --gid users --groups users
RUN useradd user --uid 1001 --password $(mkpasswd password) --home /home/user --create-home --gid users --groups users

ADD start_ssh_incontainer.sh /

#RUN echo "user    ALL=(ALL:ALL) NOPASSWD:ALL" | tee -a /etc/sudoers
RUN echo "user    ALL=(ALL:ALL) ALL" | tee -a /etc/sudoers

