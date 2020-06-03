#!/bin/bash
PATH="/usr/sbin:/usr/bin:/sbin:/bin"
IP_URL="https://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest"
DOMAIN_URL="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf"
WORKDIR=$(uci get MosChinaDNS.MosChinaDNS.workdir 2>/dev/null)
TEMPDIR="/tmp/MosChinaDNSupdatelist"

# IP/MASK
update_ip_list(){
    echo "Updating ip list"
    local tmpipfile="$TEMPDIR/ip_data"
    local tmpfile="$TEMPDIR/temp_chn.list"
    curl $IP_URL -o $tmpipfile 2>/dev/null
    if [ "$(awk 'NR==1 {print}' $tmpipfile 2>/dev/null)" = "" ]; then
        echo "received ipv4 empty body"
        EXIT 2
    fi
    cat $tmpipfile | awk -F '|' '$2 ~ /CN/ && $3 ~ /ipv6/ {print $4"/"$5}' >> $tmpfile 2>/dev/null
    cat $tmpipfile | awk -F '|' '$2 ~ /CN/ && $3 ~ /ipv4/ {print $4"/"32-log($5)/log(2)}' > $tmpfile 2>/dev/null
    if [ ! -d "$WORKDIR" ]; then
        echo $WORKDIR" is missing"
        EXIT 1
    fi
    mv -f $tmpfile "$WORKDIR/chn.list"
    echo "Updating ip finished"
}

# DOMAIN
update_domain_list(){
    echo "Updating domain list"
    local tmpdomainfile="$TEMPDIR/domain_data"
    local tmpfile="$TEMPDIR/temp_chn_domain.list"
    curl -L -k $DOMAIN_URL -o $tmpdomainfile 2>/dev/null
    if [ "$(awk 'NR==1 {print}' $tmpdomainfile 2>/dev/null)" = "" ]; then
        echo "received domain empty body"
        EXIT 3
    fi
    cat $tmpdomainfile | awk -F '/' '{print $2}' > $tmpfile 2>/dev/null
    mv -f $tmpfile "$WORKDIR/chn_domain.list"
    echo "Updating domain finished"
}
EXIT(){
    rm /var/run/update_list 2>/dev/null
    rm -rf $TEMPDIR 2>/dev/null
    [ "$1" != "0" ] && touch /var/run/update_list_error && echo $1 > /var/run/update_list_error
    exit $1
}

main(){
    touch /var/run/update_list
    rm -rf $TEMPDIR 2>/dev/null
    rm /var/run/update_list_error 2>/dev/null
    mkdir $TEMPDIR
    update_ip_list
    update_domain_list
    EXIT 0
}

main