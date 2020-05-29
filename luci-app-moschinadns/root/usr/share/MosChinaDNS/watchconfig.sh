#!/bin/sh
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
configpath=$(uci get MosChinaDNS.MosChinaDNS.configpath)
while :
do
	sleep 10
	if [ -f "$configpath" ]; then
		/etc/init.d/MosChinaDNS do_redirect 1
		break
	fi
done
return 0