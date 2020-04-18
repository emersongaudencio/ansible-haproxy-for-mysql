# ansible-haproxy-for-mysql
### Ansible Routine to setup HaProxy for MySQL

# Translation in English en-us

 In this file, I will present and demonstrate how to Install HaProxy for MySQL in an automated and easy way.

 For this, I will be using the scenario described down below:
 ```
 1 Linux server for Ansible
 ```

 First of all, we have to prepare our Linux environment to use Ansible

 Please have a look below how to install Ansible on CentOS/Red Hat:
 ```
 yum install ansible -y
 ```
 Well now that we have Ansible installed already, we need to install git to clone our git repository on the Linux server, see below how to install it on CentOS/Red Hat:
 ```
 yum install git -y
 ```

 Copying the script packages using git:
 ```
 cd /root
 git clone https://github.com/emersongaudencio/ansible-haproxy-for-mysql.git
 ```
 Alright then after we have installed Ansible and git and clone the git repository. We have to generate ssh heys to share between the Ansible control machine and the database machines. Let see how to do that down below.

 To generate the keys, keep in mind that is mandatory to generate the keys inside of the directory who was copied from the git repository, see instructions below:
 ```
 cd /root/ansible-haproxy-for-mysql
 ssh-keygen -f ansible
 ```
 After that you have had generated the keys to copy the keys to the database machines, see instructions below:
 ```
 ssh-copy-id -i ansible.pub 172.16.122.146
 ```

 Please edit the file called hosts inside of the ansible git directory :
 ```
 vi hosts
 ```
 Please add the hosts that you want to install your database and save the hosts file, see an example below:

 ```
 # This is the default ansible 'hosts' file.
 #

 ## [dbservers]
 ##
 ## db01.intranet.mydomain.net
 ## db02.intranet.mydomain.net
 ## 10.25.1.56
 ## 10.25.1.57

 [dbproxy]
 dbproxy01 ansible_ssh_host=172.16.122.128
 [dbservers]
 dbmysql57 ansible_ssh_host=172.16.122.146
 ```

 For testing if it is all working properly, run the command below :
 ```
 ansible -m ping dbproxy01 -v
 ansible -m ping dbmysql57 -v
 ```

 Alright then, finally we can perform the script to install HaProxy for MySQL on our Proxy Server/App servers using Ansible as we planned to, please execute the command below:
 ```
 sh run_haproxy_for_mysql.sh dbproxy01 3306 172.16.122.146
 ```

 Alright then, finally we can perform the script to install MySQL Check on our Database machine using Ansible as we planned to, please execute the command below:
 ```
 sh run_haproxy_mysqlchk.sh dbmysql57 mysqlchk YOURPASSWORD
 ```

### Parameters specification:

#### run_haproxy_for_mysql.sh
Parameter  | Value           | Mandatory | Order
------------ | ------------- | ------------- | -------------
host | dbproxy01 | Yes | 1
db port | 3306 | Yes | 2
Primary db server address | 172.16.122.157 | Yes | 3
Replicas db server address | 172.16.122.157 | No | 4

#### run_haproxy_mysqlchk.sh
Parameter | Value | Mandatory | Order
------------ | ------------- | ------------- | -------------
host | dbmysql57 | Yes | 1
db username | mysqlchk | Yes | 2
db user password | YOURPASSWORD | Yes | 3


Suggested grants privileges to a MySQL User for mysqlchk verification purpose on the master/slave database point it to:

```
############ Setting a proper privileges towards a database #####
CREATE USER mysqlchk@'localhost' IDENTIFIED BY 'YOURPASSWORD';
GRANT REPLICATION SLAVE ON *.* TO mysqlchk@'localhost';
flush privileges;
```
