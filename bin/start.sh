#!/bin/sh

#####################################################################
# usage:
# sh start.sh -- start application @dev
# sh start.sh ${env} -- start application @${env}

# examples:
# sh start.sh prod -- use conf/nginx-prod.conf to start OpenResty
# sh start.sh -- use conf/nginx-dev.conf to start OpenResty
#####################################################################

export LOG_PATH="/data/logs/melon"
export MELOG_PATH="/data/git/melon"

if [ ! -d $LOG_PATH ]; then
    mkdir -p $LOG_PATH
fi

if [ -n "$1" ];then
    PROFILE="$1"
else
    PROFILE=dev
fi

mkdir -p ../logs & mkdir -p ../tmp
echo "start melon application with profile: "${PROFILE}
nginx -p $(dirname $(pwd))/ -c conf/nginx-${PROFILE}.conf
