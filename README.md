
# Containers-as-servers

Scripts to create a bunch of "virtual" server machines using Docker containers.

When developing a Pexpect tutorial I wanted to have a bunch of machines to test against.

The simplest/lightest weight solution is to create a bunch of containers with OpenSSH installed and enabled.

Although use of ssh login is not the 'container' or micro-service way, this provides a neat solution
to have a bunch of 'virtual' servers for testing.

The Dockerfile creates an extension of the latest Ubuntu image, installing openssh-server, whois, sudo packages.

We also create a dummy user with username 'user' and password 'password'.
We enable sudo for this user.

The goal here is to have a machine with a known password login to test Pexpect against.
You may have other uses ...

The Pexpect tutorial uses these machines to demonstrate ssh-key insertion across a multi-hop and multi-user chain.

Assuming a chain of machines where to get to be root on host3, we must first pass by user 'user' from root@host2
To be root on host2, we must first pass by user 'user' from root@host1
To be root on host1, we must first pass by user 'user'

This was an actual use case for an OpenStack platform where access to certain controller/compute nodes is restricted
and passwords are initially unknown (only access is via ssh-keys from certain machines/accounts to certain machines/accounts).

Building the image
==================

Run ./build.sh which will create the ubuntussh Docker image.

Creating the 'virtual' servers
================================

Run ./run.sh which will launch new container instances with open-ssh running.

You can now ssh to these 'machines' as user 'user' and password 'password'.


