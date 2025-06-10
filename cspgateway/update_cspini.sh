#!/bin/bash

if [[ -n "$1" ]]
then
    sed -Ei "s/Ip_Address=cache/Ip_Address=${1}/" /opt/cspgateway/bin/CSP.ini
fi

exit 0
