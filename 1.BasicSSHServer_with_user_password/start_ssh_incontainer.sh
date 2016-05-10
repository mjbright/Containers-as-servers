#!/bin/bash

      #{ echo "Starting sshd on Alpine Linux"; /etc/init.d/sshd start; } ||

[ -f /etc/alpine-release ] && {
      while [ 1 ]; do
        echo "Starting sshd on Alpine Linux";
        /usr/sbin/sshd -d -D -f /etc/ssh/sshd_config;
      done
    } ||
    {
      echo "Starting sshd on Ubuntu Linux";
      service ssh start;
      bash
    }




