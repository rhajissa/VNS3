#!/bin/bash
log=/log/docker.log
echo "$(date +%FT%T) start" >>$log

trap onexit SIGTERM
trap onint SIGINT

function onint {
	echo "$(date +%FT%T) signal int" >>$log
	ps -ef >>$log

}

function onexit {
	# shutdown ...
	{
		echo "$(date +%FT%T) stop"
		exit
	} >> $log
}

{
	echo starte MariaDB..
    service mariadb start

	while ! mariadb -u dbuser --password='lalelu123' -e 'quit' >/dev/null 2>&1; do
	echo "Warte auf MariaDB..."
	sleep 1
	done
	echo MariaDB gestartet
	# SQL-Skript ausführen
	mariadb -u dbuser -plalelu123 -D dbdemo < /usr/bin/init_db.sql

} >>$log
sleep 1

