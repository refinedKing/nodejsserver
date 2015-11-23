#!/bin/bash
#
# description: dropbear ssh daemon
# chkconfig: 2345 66 33
#
dsskeyfile=/etc/dropbear/dropbear_dss_host_key
rsakeyfile=/etc/dropbear/dropbear_rsa_host_key
lockfile=/var/lock/subsys/dropbear
pidfile=/var/run/dropbear.pid
dropbear=/usr/local/sbin/dropbear
dropbearkey=/usr/local/bin/dropbearkey

[ -r /etc/rc.d/init.d/functions ] && . /etc/rc.d/init.d/functions
[ -r /etc/sysconfig/dropbear ] && . /etc/sysconfig/dropbear
keysize=${keysize:-1024}
port=${port:-22}

gendsskey() {
	[ -d /etc/dropbear ] || mkdir /etc/dropbear
	echo -n "Starting generate the dss key: "
	$dropbearkey -t dss -f $dsskeyfile &> /dev/null
	RETVAL=$?
	if [ $RETVAL -eq 0 ]; then
		success
		echo
		return 0
	else
		failure
		echo
		return 1
	fi	
}

genrsakey() {
	[ -d /etc/dropbear ] || mkdir /etc/dropbear
	echo -n "Starting generate the rsa key: "
	$dropbearkey -t rsa -s $keysize -f $rsakeyfile &> /dev/null
	RETVAL=$?
	if [ $RETVAL -eq 0 ]; then
		success
		echo
		return 0
	else
		failure
		echo
		return 1
	fi	
}

start() {
	[ -e $dsskey ] || gendsskey
	[ -e $rsakey ] || genrsakey

	if [ -e $lockfile ]; then
		echo -n "dropbear daemon is already running: "
		success
		echo 
		exit 0
	fi

	echo -n "Starting dropbear: "
	daemon --pidfile="$pidfile" $dropbear -p $port -d $dsskey -r $rsakey
	RETVAL=$?
	echo 

	[ $RETVAL -eq 0 ] && touch $lockfile;return 0 || rm -f $lockfile $pidfile return 1
}

stop() {
	if [ ! -e $lockfile ]; then
		echo -n "dropbear service is stopped: "
		success
		echo
		exit 1
	fi

	echo -n "Stopping dropbear daemon: "
	killproc dropbear
	RETVAL=$?
	echo
	
	[ $RETVAL -eq 0 ] && rm -f $lockfile $pidfile; return 0 || return 1
}

status() {
	[ -e $lockfile ] && echo "dropbear is running..." || echo "dropbear is stopped..."
}

usage() {
	echo "Usage: dropbear {start|stop|restart|status|gendsskey|genrsakey}"
}

case $1 in 
	start)
		start ;;
	stop)
		stop ;;
	restart)
		stop
		start ;;
	status)
		status ;;
	gendsskey)
		gendsskey ;;
	genrsakey)
		genrsakey ;;
	*)
		usage ;;
esac
