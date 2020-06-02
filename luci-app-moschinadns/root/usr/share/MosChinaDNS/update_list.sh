#!/bin/bash
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
IP_URL="https://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest"
DOMAIN_URL="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf"
workdir=$(uci get MosChinaDNS.MosChinaDNS.workdir 2>/dev/null)

# IP/MASK
update_ip_list(){
    echo "Updating ip list"
    curl $IP_URL -o /tmp/MosChinaDNSupdatelist/ip_data 2>/dev/null
    ipv4=$(cat /tmp/MosChinaDNSupdatelist/ip_data | awk -F '|' '$2 ~ /CN/ && $3 ~ /ipv4/ {print $4"/"32-log($5)/log(2)}' 2>/dev/null)
    ipv6=$(cat /tmp/MosChinaDNSupdatelist/ip_data | awk -F '|' '$2 ~ /CN/ && $3 ~ /ipv6/ {print $4"/"$5}' 2>/dev/null)
    if [ "$ipv4" = "" ]; then
        echo "received ipv4 empty body"
        EXIT 2
    fi
    echo $ipv4 > /tmp/MosChinaDNSupdatelist/temp_chn.list
    echo $ipv6 >> /tmp/MosChinaDNSupdatelist/temp_chn.list
    if [ ! -d "$workdir" ]; then
        echo $workdir" is missing"
        EXIT 1
    fi
    mv -f /tmp/MosChinaDNSupdatelist/temp_chn.list "$workdir/chn.list"
    echo "Updating ip finished"
}

# DOMAIN
update_domain_list(){
    echo "Updating domain list"
    curl -L -k $DOMAIN_URL -o /tmp/MosChinaDNSupdatelist/domain_data 2>/dev/null
    domain=$(cat /tmp/MosChinaDNSupdatelist/domain_data | awk -F '/' '{print $2}')
    if [ "$domain" = "" ]; then
        echo "received domain empty body"
        EXIT 3
    fi
    echo $domain > /tmp/MosChinaDNSupdatelist/temp_chn_domain.list
    mv -f /tmp/MosChinaDNSupdatelist/temp_chn_domain.list "$workdir/chn_domain.list"
    echo "Updating domain finished"
}
EXIT(){
    rm /var/run/update_list 2>/dev/null
    rm -rf /tmp/MosChinaDNSupdatelist 2>/dev/null
    [ "$1" != "0" ] && touch /var/run/update_list_error && echo $1 > /var/run/update_list_error
    exit $1
}

main(){
    touch /var/run/update_list
    rm -rf /tmp/MosChinaDNSupdatelist 2>/dev/null
    rm /var/run/update_list_error 2>/dev/null
    mkdir /tmp/MosChinaDNSupdatelist
    update_ip_list
    update_domain_list
    EXIT 0
}

main