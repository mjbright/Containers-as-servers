
press() {
    echo $*
    echo "Press <return> to continue [or 'q' to quit]"
    read _DUMMY
    [ "$_DUMMY" = "q" ] && exit 0
    [ "$_DUMMY" = "Q" ] && exit 0
}

RUNNING_IDS=$(docker ps -q)
[ ! -z "$RUNNING_IDS" ] && {
    echo; docker ps
    echo; press "About to stop all running containers"
    docker stop $RUNNING_IDS
}

STOPPED_IDS=$(docker ps -qa)
[ ! -z "$STOPPED_IDS" ] && {
    echo; docker ps -a
    echo; press "About to remove all stopped containers"
    docker rm $STOPPED_IDS
}

