#!/bin/bash

# TODO: if command-line argument, grep on this:

if [ -z "$1" ];then
    CONTAINER_IDS=$(docker ps -q)
else
    CONTAINER_IDS=$(docker ps | grep -a "$1" | awk '{print $1;}' )
fi

for CONTAINER_ID in $CONTAINER_IDS
do
    IP=$(docker inspect $CONTAINER_ID | jq -r '.[0].NetworkSettings.IPAddress')
    echo $IP
done

