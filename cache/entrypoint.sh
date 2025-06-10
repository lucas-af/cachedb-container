#!/usr/bin/env bash

userid=$(id -u)
echo "Starting with userid $userid"

#trap "echo 'Stopping ...'; ccontrol stop CACHE quietly;" 0 1 2 3 9 15 19

if [[ -n "$ISC_ZONEINFO" ]]
then
    ln -f -s /usr/share/zoneinfo/$ISC_ZONEINFO /etc/localtime
fi

# cache.key
if [[ ! -f /opt/isc/cache/mgr/cache.key ]]
then
    if [[ -f "$CACHE_KEY_FILE" ]]
    then
	cp -v $CACHE_KEY_FILE /opt/isc/cache/mgr/cache.key

	if [[ "$userid" == "0" ]]
	then
	    chmod -v 440 /opt/isc/cache/mgr/cache.key
	    chown -v cache:cacheusr /opt/isc/cache/mgr/cache.key
	fi	
    fi
fi

# Print Caché State
ccontrol list

# Start Caché
status_list=$(ccontrol qlist CACHE | cut -d '^' -f 4 | cut -d ',' -f 1)
if [[ $status_list == 'down' ]]
then
    sleep 5
    rm -v /opt/isc/cache/mgr/cconsole.log
    
    echo -e '\n\nStart Cache Database ...'
    status_start=
    if [[ "$userid" == "0" ]]
    then
	su -l cache -c 'ccontrol start CACHE' 
	status_start=$?
    else
	ccontrol start CACHE
	status_start=$?
    fi
    
    [[ $status_start -ne 0 ]] && exit $status_start

    # Print Caché State
    ccontrol list    
fi

echo "Params: ${#@}"
if [[ ${#@} -ne 0 ]]
then
    exec "$@"
fi

