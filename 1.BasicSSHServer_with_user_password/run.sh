
#IMAGE=mjbright/ubuntussh
IMAGE=mjbright/alpinessh

die() {
    echo "$0: die - $*" >&2
    exit 1
}

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

docker ps | grep container && die "Containers already running"

#CONTAINER_ID1=$(docker run -itd $IMAGE "service ssh start; bash")
#for num in 1 2 3;do
#done
CONTAINER_ID1=$(docker run --name container1 -h container1 -itd $IMAGE "/start_ssh_incontainer.sh")
CONTAINER_ID2=$(docker run --name container2 -h container2 -itd $IMAGE "/start_ssh_incontainer.sh")
CONTAINER_ID3=$(docker run --name container3 -h container3 -itd $IMAGE "/start_ssh_incontainer.sh")
#CONTAINER_ID=$(docker run -itd $IMAGE bash)

getIP() {
    CONTAINER_ID=$1
    
    #docker inspect $CONTAINER_ID | jq -r '.[0].NetworkSettings.IPAddress'

    # Adapted to limited packages of base Alpine image:
    docker inspect $CONTAINER_ID | 
        grep \"IPAddress | tail -1 | sed -e 's/.*: "//' -e 's/".*//'
}

set -x
IP1=$(getIP $CONTAINER_ID1)
IP2=$(getIP $CONTAINER_ID2)
IP3=$(getIP $CONTAINER_ID3)

sleep 10

ssh -t user@$IP1 "sudo hostname"
ssh -t user@$IP2 "sudo hostname"
ssh -t user@$IP3 "sudo hostname"
set +x


