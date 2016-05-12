
#IMAGE=mjbright/ubuntussh
IMAGE=mjbright/alpinessh

## -- Functions ---------------------------------------------------------
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
        return
    }

    docker ps -a | grep $NAME && {
        die "You need to remove stopped containers first";
    }

    CMD="docker run --name $NAME -h $NAME -itd $IMAGE /start_ssh_incontainer.sh"
    echo $CMD
    CONTAINER_ID=$($CMD)

    [ -z "$CONTAINER_ID" ] && die "Failed to start container"
}

step_banner() {
    echo
    echo "-- $(date): $*"
}

## -- Process args ------------------------------------------------------

if [ "$1" = "stop" ];then
    IDS=$(docker ps -q); docker stop $IDS; docker rm $IDS
    exit 0
fi

## -- Functions ---------------------------------------------------------

KEY=~/.ssh/id_rsa
#step_banner "Checking presence of $KEY"
[ ! -f $KEY ] && {
    echo "No ssh key<$KEY>: creating ...";
    ssh-keygen -y -N '' -f $KEY;
    ls -altr ${KEY}*
}

## -- Main --------------------------------------------------------------

step_banner "Starting container[123]"
docker_run "container1" $IMAGE; CONTAINER_ID1=$CONTAINER_ID
docker_run "container2" $IMAGE; CONTAINER_ID2=$CONTAINER_ID
docker_run "container3" $IMAGE; CONTAINER_ID3=$CONTAINER_ID

#set -x
step_banner "Getting IP Addresses of container[123]"
IP1=$(getIP $CONTAINER_ID1)
IP2=$(getIP $CONTAINER_ID2)
IP3=$(getIP $CONTAINER_ID3)

[ -z "$IP1" ] && die "Failed to get ip address of $CONTAINER_ID1)"
[ -z "$IP2" ] && die "Failed to get ip address of $CONTAINER_ID2)"
[ -z "$IP3" ] && die "Failed to get ip address of $CONTAINER_ID3)"
echo "--> $IP1 $IP2 $IP3"

step_banner "Waiting for ssh port to open on container[123]"
waitOnPort $IP1 22
waitOnPort $IP2 22
waitOnPort $IP3 22

step_banner "Removing old keys from ~/.ssh/known_hosts"
{
    ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R $IP1;
    ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R $IP2;
    ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R $IP3;
} >/dev/null 2>&1

step_banner "Adding new keys to ~/.ssh/known_hosts"
{
    ssh-keyscan -H $IP1 >> ~/.ssh/known_hosts
    ssh-keyscan -H $IP2 >> ~/.ssh/known_hosts
    ssh-keyscan -H $IP3 >> ~/.ssh/known_hosts
} >/dev/null 2>&1

step_banner "Check ssh connection to container[123]"
#ssh -t user@$IP1 "sudo hostname"
#ssh -t user@$IP2 "sudo hostname"
#ssh -t user@$IP3 "sudo hostname"
CMD='ssh user@'$IP1' echo My hostname=$(hostname)'
echo "---- Output of '$CMD':"; $CMD
CMD='ssh user@'$IP2' echo My hostname=$(hostname)'
echo "---- Output of '$CMD':"; $CMD
CMD='ssh user@'$IP3' echo My hostname=$(hostname)'
echo "---- Output of '$CMD':"; $CMD
#set +x


