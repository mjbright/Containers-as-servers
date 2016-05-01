
if [ "$1" = "stop" ];then
    IDS=$(docker ps -q); docker stop $IDS; docker rm $IDS
    exit 0
fi

KEY=~/.ssh/id_rsa
[ ! -f $KEY ] && {
    echo "No ssh key<$KEY>: creating ...";
    ssh-keygen -y -N '' -f $KEY;
    ls -altr ${KEY}*
}

#CONTAINER_ID1=$(docker run -itd mjbright/ubuntussh "service ssh start; bash")
#for num in 1 2 3;do
#done
CONTAINER_ID1=$(docker run --name container1 -h container1 -itd mjbright/ubuntussh "/start_ssh_incontainer.sh")
CONTAINER_ID2=$(docker run --name container2 -h container2 -itd mjbright/ubuntussh "/start_ssh_incontainer.sh")
CONTAINER_ID3=$(docker run --name container3 -h container3 -itd mjbright/ubuntussh "/start_ssh_incontainer.sh")
#CONTAINER_ID=$(docker run -itd mjbright/ubuntussh bash)

set -x
IP1=$(docker inspect $CONTAINER_ID1 | jq -r '.[0].NetworkSettings.IPAddress')
IP2=$(docker inspect $CONTAINER_ID2 | jq -r '.[0].NetworkSettings.IPAddress')
IP3=$(docker inspect $CONTAINER_ID3 | jq -r '.[0].NetworkSettings.IPAddress')

sleep 10

ssh -t user@$IP1 "sudo hostname"
ssh -t user@$IP2 "sudo hostname"
ssh -t user@$IP3 "sudo hostname"
set +x




