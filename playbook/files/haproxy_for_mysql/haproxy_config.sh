#!/bin/bash
echo "HOSTNAME: " `hostname`
echo "BEGIN - [`date +%d/%m/%Y" "%H:%M:%S`]"
echo "##############"

PORT=${1}
PRIMARY=${2}
BACKUP=${3}

total_backup=`echo $BACKUP | wc -w`

if [ $total_backup -gt 0 ]; then
counter=$total_backup
cnt=1
echo "" > /tmp/SERVERS
while [ $counter -gt 0 ]
 do
   for SERVERS in $BACKUP; do
    echo $"server db$(( $cnt + 1 ))-live.a $SERVERS:$PORT check non-stick backup \n       " >> /tmp/SERVERS; ec=$?
    if [ $ec -ne 0 ]; then
         echo "Script execution failed - `date +"%Y-%m-%d_%T"`"
         exit 1
    else
    cnt=$(( $cnt + 1 ))
    counter=$(( $counter - 1 ))
    fi
  done;
 done;

BACKUP_ADDRESS=$(cat /tmp/SERVERS)
BACKUP_ADDRESS=$(echo -en $BACKUP_ADDRESS)

FRONT_BACKEND_RO="frontend frontend_mysql_ro
        bind 127.0.0.1:3307
        mode tcp
        default_backend backend_mysql_ro"

MYSQL_BACKEND_RO="# ------------------------------------------------- #
# Backend - MySQL Servers for read only workload    #
# ------------------------------------------------- #
backend backend_mysql_ro
 mode tcp
 balance first
 option httpchk
 default-server port 9200 maxconn 1000 fall 15 rise 5 inter 5s downinter 10s on-marked-down shutdown-sessions on-marked-up shutdown-backup-sessions
 $BACKUP_ADDRESS"

fi

PRIMARY_ADDRESS="server db1-live.a $PRIMARY:$PORT check non-stick"

echo $PRIMARY_ADDRESS
echo $BACKUP_ADDRESS

echo "# ------------------------------------------------- #
# Global settings                                   #
# ------------------------------------------------- #
global
    log         127.0.0.1 local2 debug
    daemon
    stats socket /var/run/haproxy.sock mode 660 user root group haproxy level user

# ------------------------------------------------- #
# Defaults                                          #
# ------------------------------------------------- #
defaults
    log                     global
    retries                 2
    timeout connect         3s
    timeout client          8h
    timeout server          8h
    timeout tunnel          8h

# ------------------------------------------------- #
# Stats and admin interface                         #
# ------------------------------------------------- #
listen stats
        bind :9200
        mode http
        stats enable
        stats uri /
        stats realm Haproxy\ Statistics
        stats auth proxyadmin:test123
        stats admin if TRUE

# ------------------------------------------------- #
# Frontend                                          #
# ------------------------------------------------- #
frontend frontend_mysql
        bind 127.0.0.1:3306
        mode tcp
        default_backend backend_mysql

$FRONT_BACKEND_RO
# ------------------------------------------------- #
# Backend - MySQL Servers with only one master      #
# ------------------------------------------------- #
backend backend_mysql
 mode tcp
 balance first
 option httpchk
 default-server port 9200 maxconn 1000 fall 15 rise 5 inter 5s downinter 10s on-marked-down shutdown-sessions on-marked-up shutdown-backup-sessions
 $PRIMARY_ADDRESS
 $BACKUP_ADDRESS

$MYSQL_BACKEND_RO" > /etc/haproxy/haproxy.cfg

### start haproxy service ###
systemctl enable haproxy.service
systemctl restart haproxy.service

echo "##############"
echo "END - [`date +%d/%m/%Y" "%H:%M:%S`]"
