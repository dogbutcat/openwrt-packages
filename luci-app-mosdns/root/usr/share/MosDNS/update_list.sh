#!/bin/bash
PATH="/usr/sbin:/usr/bin:/sbin:/bin"

IP_URL="https://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest"
DOMAIN_URL="https://raw.githubusercontent.com/felixonmars/dnsmasq-china-list/master/accelerated-domains.china.conf"
WORKDIR=$(uci get MosDNS.MosDNS.workdir 2>/dev/null)
TEMPDIR="/tmp/MosDNSupdatelist"

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

DOWNLOAD_LINK_GEOIP="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geoip.dat"
DOWNLOAD_LINK_GEOSITE="https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat"

download_geoip() {
    echo "Starting Download GEOIP: ${DOWNLOAD_LINK_GEOIP}"
    if ! curl -L -H 'Cache-Control: no-cache' -o "${TEMPDIR}/geoip.dat.new" "$DOWNLOAD_LINK_GEOIP"; then
        echo 'error: Download failed! Please check your network or try again.'
        EXIT 4
    fi
    if ! curl -L -H 'Cache-Control: no-cache' -o "${TEMPDIR}/geoip.dat.sha256sum.new" "$DOWNLOAD_LINK_GEOIP.sha256sum"; then
        echo 'error: Download failed! Please check your network or try again.'
        EXIT 5
    fi
    SUM="$(sha256sum ${TEMPDIR}/geoip.dat.new | sed 's/ .*//')"
    CHECKSUM="$(sed 's/ .*//' ${TEMPDIR}/geoip.dat.sha256sum.new)"
    if [[ "$SUM" != "$CHECKSUM" ]]; then
        echo 'error: Check failed! Please check your network or try again.'
        EXIT 6
    fi
}

download_geosite() {
    echo "Starting Download GEOSITE: ${DOWNLOAD_LINK_GEOSITE}"
    if ! curl -L -H 'Cache-Control: no-cache' -o "${TEMPDIR}/geosite.dat.new" "$DOWNLOAD_LINK_GEOSITE"; then
        echo 'error: Download failed! Please check your network or try again.'
        EXIT 7
    fi
    if ! curl -L -H 'Cache-Control: no-cache' -o "${TEMPDIR}/geosite.dat.sha256sum.new" "$DOWNLOAD_LINK_GEOSITE.sha256sum"; then
        echo 'error: Download failed! Please check your network or try again.'
        EXIT 8
    fi
    SUM="$(sha256sum ${TEMPDIR}/geosite.dat.new | sed 's/ .*//')"
    CHECKSUM="$(sed 's/ .*//' ${TEMPDIR}/geosite.dat.sha256sum.new)"
    if [[ "$SUM" != "$CHECKSUM" ]]; then
        echo 'error: Check failed! Please check your network or try again.'
        EXIT 9
    fi
}

rename_new() {
    for DAT in 'geoip' 'geosite'; do
        mv "${TEMPDIR}/$DAT.dat.new" "${WORKDIR}/$DAT.dat"
        # rm "${TEMPDIR}/$DAT.dat.new"
        rm "${TEMPDIR}/$DAT.dat.sha256sum.new"
    done
}

EXIT(){
    rm /var/run/update_dat 2>/dev/null
    rm -rf $TEMPDIR 2>/dev/null
    [ "$1" != "0" ] && touch /var/run/update_dat_error && echo $1 > /var/run/update_dat_error
    exit $1
}

main(){
    touch /var/run/update_dat
    rm -rf $TEMPDIR 2>/dev/null
    rm /var/run/update_dat_error 2>/dev/null
    mkdir $TEMPDIR

    # no more need download ip list and domain list
    # update_ip_list
    # update_domain_list

    download_geoip
    download_geosite
    rename_new
    EXIT 0
}

main