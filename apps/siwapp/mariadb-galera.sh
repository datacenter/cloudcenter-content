#!/bin/bash -x
exec > >(tee -a /var/tmp/maria-node-init_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh
. /usr/local/osmosix/service/utils/agent_util.sh

# agentSendLogMessage $(env)

sudo su -c "cat <<EOF > /etc/yum.repos.d/MariaDB.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
"
sudo mv /etc/yum.repos.d/cliqr.repo ~

sudo rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
sudo groupadd -g 250 -r mysql
sudo useradd -u 250 -r -g mysql mysql
sudo yum update -y
sudo yum -y install MariaDB-server MariaDB-client galera less which socat pwgen firewalld nmap
sudo yum install expect -y
sudo yum clean all

sudo systemctl enable mariadb
sudo systemctl start mariadb

# mysql secure installation
CURRENT_MYSQL_PASSWORD=''
NEW_MYSQL_PASSWORD="${GALERA_DB_ROOT_PWD}"

SECURE_MYSQL=$(sudo expect -c "

set timeout 3
spawn mysql_secure_installation

expect \"Enter current password for root (enter for none):\"
send \"$CURRENT_MYSQL_PASSWORD\r\"

expect \"root password?\"
send \"y\r\"

expect \"New password:\"
send \"$NEW_MYSQL_PASSWORD\r\"

expect \"Re-enter new password:\"
send \"$NEW_MYSQL_PASSWORD\r\"

expect \"Remove anonymous users?\"
send \"y\r\"

expect \"Disallow root login remotely?\"
send \"y\r\"

expect \"Remove test database and access to it?\"
send \"y\r\"

expect \"Reload privilege tables now?\"
send \"y\r\"

expect eof
")

# Execution mysql_secure_installation
echo "${SECURE_MYSQL}"

# create galera db user and privs
mysql -u root -p$GALERA_DB_ROOT_PWD <<-EOF
DELETE FROM mysql.user WHERE User='';
GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$GALERA_DB_ROOT_PWD';
GRANT USAGE ON *.* to $GALERA_DB_USER@'%' IDENTIFIED BY '$GALERA_DB_USER_PWD';
GRANT ALL PRIVILEGES on *.* to $GALERA_DB_USER@'%';
FLUSH PRIVILEGES;
EOF


sudo systemctl stop mariadb
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --add-port=4567/tcp --permanent
sudo firewall-cmd --add-port=4568/tcp --permanent
sudo firewall-cmd --add-port=4444/tcp --permanent
sudo firewall-cmd --add-port=3306/tcp --permanent
sudo firewall-cmd --add-port=9200/tcp --permanent
sudo firewall-cmd --reload

temp_ifs=${IFS}
IFS=','
nodeArr=(${CliqrTier_siwapp_mariadb_NODE_ID}) # Array of nodes in my tier.
ipArr=(${CliqrTier_siwapp_mariadb_PUBLIC_IP}) # Array of IPs in my tier.
master=${nodeArr[0]} # Let the first node in the service tier be the master.
master_addr=${ipArr[0]} # Let the first node in the service tier be the master.

# Iterate through list of hosts to find this hosts's index in the array for later use.
host_index=0
for host in $CliqrTier_siwapp_mariadb_HOSTNAME ; do
    if [ ${host} = ${cliqrNodeHostname} ]; then
        # INDEX for this host is current position in array.
        echo "Index: ${host_index}"
        break
    fi
    let host_index=${host_index}+1
done

my_addr=${ipArr[${host_index}]}
echo ${my_addr}

IFS=${temp_ifs}


# MYSQL Config Settings
sudo su -c "cat << EOF > /etc/my.cnf.d/server.cnf
[mysql]

# This config is tuned for a 4xCore, 8GB Ram DB Host

# CLIENT #
port                           = 3306
socket                         = /var/lib/mysql/mysql.sock

[mysqld]

# GENERAL #
user                           = mysql
default-storage-engine         = InnoDB
socket                         = /var/lib/mysql/mysql.sock
pid-file                       = /var/lib/mysql/mysql.pid
bind-address                   = 0.0.0.0

# CHARACTER SET #
collation-server               = utf8_unicode_ci 
init-connect                   = 'SET NAMES utf8'
character-set-server           = utf8


# MyISAM #
key-buffer-size                = 32M
myisam-recover-options         = FORCE,BACKUP

# SAFETY #
skip-host-cache
skip-name-resolve

# DATA STORAGE #
datadir                        = /var/lib/mysql

# BINARY LOGGING #
log-bin                        = /var/lib/mysql/mysql-bin
expire-logs-days               = 14
# Disabling for performance per http://severalnines.com/blog/9-tips-going-production-galera-cluster-mysql
sync-binlog                    = 0
# Required for Galera
binlog-format                  = row

# CACHES AND LIMITS #
tmp-table-size                 = 32M
max-heap-table-size            = 32M
# Re-enabling as now works with Maria 10.1.2
query-cache-type               = 1
query-cache-limit              = 2M
query-cache-size               = 64M
max-connections                = 500
thread-cache-size              = 50
open-files-limit               = 65535
table-definition-cache         = 4096
table-open-cache               = 4096

# INNODB #
innodb-flush-method            = O_DIRECT
innodb-log-files-in-group      = 2
innodb-log-file-size           = 128M
innodb-flush-log-at-trx-commit = 1
innodb-file-per-table          = 1
# 80% Memory is default reco.
# Need to re-evaluate when DB size grows
innodb-buffer-pool-size        = 1456M
innodb_file_format             = Barracuda


# LOGGING #
log-error                      = /dev/stdout
slow-query-log-file            = /dev/stdout
log-queries-not-using-indexes  = 1
slow-query-log                 = 1

# GALERA SETTINGS #
[galera]
wsrep_on                       = ON
wsrep_provider                 = /usr/lib64/galera/libgalera_smm.so
wsrep_sst_method               = rsync
wsrep_slave_threads            = 4
innodb-flush-log-at-trx-commit = 2
wsrep_cluster_address          = 'gcomm://${CliqrTier_siwapp_mariadb_PUBLIC_IP}'
wsrep_cluster_name             = '${GALERA_CLUSTER_NAME}'
wsrep_node_address             = '${my_addr}'
wsrep_node_name                = '${cliqrNodeHostname}'

# MYISAM REPLICATION SUPPORT #
wsrep_replicate_myisam         = ON
EOF
"


if [ "${master}" == "${cliqrNodeId}" ]; then
    # I'm the master
    agentSendLogMessage "Master"
    agentSendLogMessage "Initializing master..."
    sudo galera_new_cluster
    #Download and restore old database
    agentSendLogMessage "Downloading SQL file and restoring database."
    curl -o /tmp/siwapp.sql https://raw.githubusercontent.com/datacenter/cloudcenter-content/${siwapp_git_tag}/apps/siwapp/siwapp.sql
    sudo su -c "mysql -u root -p'${GALERA_DB_ROOT_PWD}' < /tmp/siwapp.sql"
    sudo su -c "mysql -u root -p'${GALERA_DB_ROOT_PWD}' -e 'CREATE USER haproxy; FLUSH PRIVILEGES;'"

else
    agentSendLogMessage  "Waiting for master node to be initialized..."
    COUNT=0
    MAX=50
    SLEEP_TIME=5
    ERR=0

    # Keep checking for port 3306 on the master to be open
    until $(mysql -h $master_addr -u root -p"${GALERA_DB_ROOT_PWD}" -e ""); do
      sleep ${SLEEP_TIME}
      let "COUNT++"
      echo ${COUNT}
      if [ ${COUNT} -gt ${MAX} ]; then
        ERR=1
        break
      fi
    done
    if [ ${ERR} -ne 0 ]; then
        agentSendLogMessage "Failed to find port 3306 open on master node, so guessing something is wrong."
        exit 1
    else
        agentSendLogMessage "starting slave"
        sudo systemctl start mariadb
    fi
fi

sudo mv ~/cliqr.repo /etc/yum.repos.d/
