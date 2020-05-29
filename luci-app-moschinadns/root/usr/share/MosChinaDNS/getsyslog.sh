#!/bin/sh
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
logread -e MosChinaDNS > /tmp/MosChinaDNStmp.log
logread -e MosChinaDNS -f >> /tmp/MosChinaDNStmp.log &
pid=$!
echo "1">/var/run/MosChinaDNSsyslog
while true
do
	sleep 12
	watchdog=$(cat /var/run/MosChinaDNSsyslog)
	if [ "$watchdog"x == "0"x ]; then
		kill $pid
		rm /tmp/MosChinaDNStmp.log
		rm /var/run/MosChinaDNSsyslog
		exit 0
	else
		echo "0">/var/run/MosChinaDNSsyslog
	fi
done