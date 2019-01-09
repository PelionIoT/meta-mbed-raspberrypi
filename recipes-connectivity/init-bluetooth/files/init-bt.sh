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

stop() {
    if [ -f $PIDFILE ]; then
        PID=`cat $PIDFILE`
        kill $PID
        if [ "$?" -ne "0" ]; then
            echo "init-pt kill failed"
        else
            echo "Killed init-pt $PID"
        fi
        rm -f $PIDFILE
    else
        echo "Pidfile not found"
    fi
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    *)
    echo "Usage: $0 {start|stop}"
esac
