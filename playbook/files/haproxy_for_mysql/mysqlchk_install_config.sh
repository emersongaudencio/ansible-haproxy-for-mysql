#!/bin/bash
verify_xinetd=`rpm -qa | grep xinetd`
if [[ $verify_xinetd == "xinetd"* ]]
then
  echo "$verify_xinetd is installed!"
else

### install xinetd #####
yum -y install xinetd telnet

user=${1}
pass=${2}

### copy from /tmp directory ###
cd /tmp
cp mysqlchk /usr/local/bin/
chown nobody: /usr/local/bin/mysqlchk
chmod 744 /usr/local/bin/mysqlchk
touch /opt/.mysqlchk.cnf
echo "[client]
user            = ${user}
password        = ${pass}
port            = 3306
socket          = /var/lib/mysql/mysql.sock
" >> /opt/.mysqlchk.cnf
chown nobody: /opt/.mysqlchk.cnf

##### Add mysqlchck in the last line ###########################
# /etc/services
echo ' ' >> /etc/services
echo '# mysqlchk preps' >> /etc/services
echo 'mysqlchk        9200/tcp                # mysqlchk' >> /etc/services

echo ' '                                               >  /etc/xinetd.d/mysqlchk
echo '# mysql'                                         >> /etc/xinetd.d/mysqlchk
echo '# default: on'                                   >> /etc/xinetd.d/mysqlchk
echo '# description: mysqlchk'                         >> /etc/xinetd.d/mysqlchk
echo 'service mysqlchk'                                >> /etc/xinetd.d/mysqlchk
echo '{ '                                              >> /etc/xinetd.d/mysqlchk
echo '  disable            = no'                       >> /etc/xinetd.d/mysqlchk
echo '  flags              = REUSE'                    >> /etc/xinetd.d/mysqlchk
echo '  socket_type        = stream'                   >> /etc/xinetd.d/mysqlchk
echo '  port               = 9200'                     >> /etc/xinetd.d/mysqlchk
echo '  wait               = no'                       >> /etc/xinetd.d/mysqlchk
echo '  user               = nobody'                   >> /etc/xinetd.d/mysqlchk
echo '  server             = /usr/local/bin/mysqlchk'  >> /etc/xinetd.d/mysqlchk
echo '  log_on_failure     += USERID'                  >> /etc/xinetd.d/mysqlchk
echo '  log_on_success     ='                          >> /etc/xinetd.d/mysqlchk
echo '  only_from          = 0.0.0.0/0'                >> /etc/xinetd.d/mysqlchk
echo '  per_source         = UNLIMITED'                >> /etc/xinetd.d/mysqlchk
echo '}'                                               >> /etc/xinetd.d/mysqlchk
echo ' '                                               >> /etc/xinetd.d/mysqlchk

### starting xinetd service ###
systemctl enable xinetd.service
systemctl restart xinetd.service
sleep 5

## testing the service ####
#telnet 127.0.0.1 9200
sh /usr/local/bin/mysqlchk
fi
