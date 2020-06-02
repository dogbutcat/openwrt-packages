#!/bin/bash
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
IP_URL="https://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest"
DOMAIN_URL="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf"
workdir=$(uci get MosChinaDNS.MosChinaDNS.workdir 2>/dev/null)

# IP/MASK
update_ip_list(){
    echo "Updating ip list"
    ip_data=$(curl $IP_URL 2>/dev/null)
    ipv4=$(echo $ip_data | awk -F '|' '$2 ~ /CN/ && $3 ~ /ipv4/ {print $4"/"32-log($5)/log(2)}' 2>/dev/null)
    ipv6=$(echo $ip_data | awk -F '|' '$2 ~ /CN/ && $3 ~ /ipv6/ {print $4"/"$5}' 2>/dev/null)
    if [ "$ipv4" = "" ]; then
        echo "received ipv4 empty body"
        EXIT 2
    fi
    echo $ipv4 > /tmp/temp_chn.list
    echo $ipv6 >> /tmp/temp_chn.list
    if [ ! -f "$workdir" ]; then
        echo "please make a config first"
        EXIT 1
    fi
    mv -f /tmp/temp_chn.list "$workdir/chn.list"
    echo "Updating ip finished"
}

# DOMAIN
update_domain_list(){
    echo "Updating domain list"
    domain_data=$(curl -L -k $DOMAIN_URL)
    domain=$(echo $domain_data | awk -F '/' '{print $2}')
    if [ "$domain" = "" ]; then
        echo "received domain empty body"
        EXIT 3
    fi
    echo $domain > /tmp/temp_chn_domain.list
    mv -f /tmp/temp_chn_domain.list "$workdir/chn_domain.list"
    echo "Updating domain finished"
}
EXIT(){
    rm /var/run/update_list 2>/dev/null
    [ "$1" != "0" ] && touch /var/run/update_list_error && echo $1 > /var/run/update_list_error
    EXIT $1
}

main(){
	trap "EXIT 1" SIGTERM SIGINT
	touch /var/run/update_list
	rm /var/run/update_list_error 2>/dev/null
    update_ip_list
    update_domain_list
    EXIT 0
}

main