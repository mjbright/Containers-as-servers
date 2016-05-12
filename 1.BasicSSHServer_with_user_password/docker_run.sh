
#IMAGE=mjbright/ubuntussh
IMAGE=mjbright/alpinessh

die() {
    echo "$0: die - $*" >&2
    exit 1
}

waitOnPort() {
    HOST=$1; shift;
    PORT=$1; shift;

    WAIT=2
    SLEEP=1

    echo "Waiting for port $PORT to open on host $HOST"
    while ! nc -v -w $WAIT $HOST $PORT </dev/null >/dev/null 2>&1; do
        echo "Retrying ... $HOST:$PORT"; sleep $SLEEP;
    done
    echo "Open"
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

getIP() {
    CONTAINER_ID=$1
    
    #docker inspect $CONTAINER_ID | jq -r '.[0].NetworkSettings.IPAddress'

    # Adapted to limited packages of base Alpine image:
    docker inspect $CONTAINER_ID | 
        grep \"IPAddress | tail -1 | sed -e 's/.*: "//' -e 's/".*//'
}

docker_run() {
    NAME=$1; shift
    IMAGE=$1; shift

    docker ps | grep $NAME && {
        echo "Container1 already running"
        CONTAINER_ID=$(docker ps | grep $NAME | awk '{print $1;}')
    } || {
        CMD="docker run --name $NAME -h $NAME -itd $IMAGE /start_ssh_incontainer.sh"
        echo $CMD
        CONTAINER_ID=$($CMD)
    }

    [ -z "$CONTAINER_ID" ] && die "Failed to start container"
}


docker_run "container1" $IMAGE; CONTAINER_ID1=$CONTAINER_ID
docker_run "container2" $IMAGE; CONTAINER_ID2=$CONTAINER_ID
docker_run "container3" $IMAGE; CONTAINER_ID3=$CONTAINER_ID

#set -x
IP1=$(getIP $CONTAINER_ID1)
IP2=$(getIP $CONTAINER_ID2)
IP3=$(getIP $CONTAINER_ID3)

[ -z "$IP1" ] && die "Failed to get ip address of $CONTAINER_ID1)"
[ -z "$IP2" ] && die "Failed to get ip address of $CONTAINER_ID2)"
[ -z "$IP3" ] && die "Failed to get ip address of $CONTAINER_ID3)"

waitOnPort $IP1 22
waitOnPort $IP2 22
waitOnPort $IP3 22

ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R $IP1
ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R $IP2
ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R $IP3

#ssh -t user@$IP1 "sudo hostname"
#ssh -t user@$IP2 "sudo hostname"
#ssh -t user@$IP3 "sudo hostname"
ssh user@$IP1 "sudo hostname"
ssh user@$IP2 "sudo hostname"
ssh user@$IP3 "sudo hostname"
#set +x


