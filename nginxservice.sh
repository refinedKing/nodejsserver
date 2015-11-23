#!/bin/bash
#

PATH=$PATH
NAME=nginx
SBINPATH=/usr/local/nginx/sbin/$NAME
CONFIGFILE=/usr/local/nginx/$NAME.conf
PIDFILE=/usr/local/nginx/logs/$NAME.pid

[ -e "$SBINPATH" ] || echo -n "$SBINPATH No such file or directory"
[ -e "$CONFIGFILE" ] || exit -n "$CONFIGFILE No such file or directory"

start() {
	$SBINPATH -c $CONFIGFILE || echo -n "nginx already running"
}

stop() {
	kill -INT `cat $PIDFILE` || echo -n "nginx not running"
}

case "$1" in
	start )
		echo -n "$NAME Starting..."
		start
		;;
	stop )
		echo -n "$NAME Stopping..."
		stop
		;;
	restart )
		echo -n "$NAME Restarting..."
		stop
		start
		;;
	* )
		echo "Usage: /etc/init.d/$NAME  {start | stop | restart }" &> /dev/null
			exit 1
		;;
esac

exit 0
