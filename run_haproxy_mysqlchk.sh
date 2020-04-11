#!/bin/bash

export SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
export PYTHON_BIN=/usr/bin/python
export ANSIBLE_CONFIG=$SCRIPT_PATH/ansible.cfg

cd $SCRIPT_PATH

VAR_HOST=${1}
VAR_MYSQL_USER=${2}
VAR_MYSQL_PASSWORD=${3}

if [ "${VAR_HOST}" == '' ] ; then
  echo "No host specified. Please have a look at README file for futher information!"
  exit 1
fi

if [ "${VAR_MYSQL_USER}" == '' ] ; then
  echo "No MySQL User specified. Please have a look at README file for futher information!"
  exit 1
fi

if [ "${VAR_MYSQL_PASSWORD}" == '' ] ; then
  echo "No MySQL Password specified. Please have a look at README file for futher information!"
  exit 1
fi

### Ping host ####
ansible -i $SCRIPT_PATH/hosts -m ping $VAR_HOST -v

### Haproxy Check setup ####
ansible-playbook -v -i $SCRIPT_PATH/hosts -e "{mysql_user: '$VAR_MYSQL_USER', mysql_password: '$VAR_MYSQL_PASSWORD'}" $SCRIPT_PATH/playbook/haproxy_mysqlchk.yml -l $VAR_HOST
