#!/bin/sh

PIDFILE=/var/run/init-bt.pid
start() {
    if [ ! -d "/sys/class/bluetooth/hci0" ]; then
        PID=`btattach -B /dev/ttyAMA0 -P bcm -S 921600 > /var/log/btattach.log 2>&1 & echo $!`
        if [ -z $PID ]; then
	    echo "btattach failed"
	else
            sleep 1
            ps $PID
            if [ "$?" -ne "0" ]; then
                echo "btattach stopped after starting"
                return
            fi
	    echo $PID > $PIDFILE
	    echo "btattach completed"
	fi
    else
        echo "/sys/class/bluetooth/hci0 already exists."
    fi
}

case "$1" in
    start)
        start
        ;;
    *)
    echo "Usage: $0 {start}"
esac
