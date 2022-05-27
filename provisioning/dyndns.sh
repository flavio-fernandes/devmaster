#!/bin/bash

# Usage: $0 [--force [<IP>]]

# Create a file called $DYNDNSINFO that has the
# dns host and access info. Example:
#
# # https://domains.google.com/m/registrar/flaviof.dev/dns
# USERNAME='flaviof'
# PASSWORD='superSecret'
# HOST='rh.flaviof.dev'

DYNDNSINFO='/home/vagrant/.dyndns_devmaster'
#set -o xtrace
set -o errexit

function get_device() {
    ip route get 10.0.0.1 2>/dev/null | grep '10.0.0.1 via ' | grep -oP "(?<= dev )[^ ]+" | head -1
}

function get_ip() {
    DEV=${1:-'bridge0'}
    ip -4 addr show $DEV 2>/dev/null | grep -oP "(?<=inet ).*(?=/)" | head -1
}

function update_dns() {
    USERNAME=$1
    PASSWORD=$2
    HOST=$3
    IP=$4

    wget --quiet \
     --user ${USERNAME} \
     --password ${PASSWORD} \
     --method POST \
     --header 'User-Agent: wget' \
     --header 'cache-control: no-cache' \
     --output-document \
     - "https://domains.google.com/nic/update?hostname=${HOST}&myip=${IP}"
    echo ''
}

DEV=$(get_device)
IP=$(get_ip $DEV)
cd "$(dirname $0)"
source ${DYNDNSINFO}
[ -n "${USERNAME}" ] || { >&2 echo "no USERNAME, no deal"; exit 1; }
[ -n "${PASSWORD}" ] || { >&2 echo "no PASSWORD, no deal"; exit 2; }
[ -n "${HOST}" ] || { >&2 echo "no HOST, no deal"; exit 3; }
[ -n "${IP}" ] || { >&2 echo "no ip, no deal"; exit 4; }

# check if this is needed at all by doing a dns lookup
if [ "$1" == "--force" ] || [ "$1" == "-f" ]; then
    CURR_DNS_IP=''
    [ -n "$2" ] && IP="$2"
else
    CURR_DNS_IP=$(dig ${HOST} +short 2>/dev/null)
fi

echo "x${CURR_DNS_IP}" | grep --quiet "${IP}" && \
    echo "${HOST} is ${IP} already: noop" || \
    update_dns ${USERNAME} ${PASSWORD} ${HOST} ${IP}

