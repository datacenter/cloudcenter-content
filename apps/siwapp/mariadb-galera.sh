#!/bin/bash
cat <<EOF > /etc/yum.repos.d/MariaDB.repo
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.1/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF

rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB && \
groupadd -g 250 -r mysql && useradd -u 250 -r -g mysql mysql && \
yum -y install MariaDB-server MariaDB-client galera less which socat pwgen && yum clean all && \
yum install expect -y

systemctl enable mariadb
systemctl start mariadb

# mysql secure installation
CURRENT_MYSQL_PASSWORD=''
NEW_MYSQL_PASSWORD="$GALERA_DB_ROOT_PWD"

SECURE_MYSQL=$(expect -c "

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


systemctl stop mariadb
firewall-cmd --add-port=4567/tcp --permanent
firewall-cmd --add-port=4568/tcp --permanent
firewall-cmd --add-port=4444/tcp --permanent
firewall-cmd --add-port=3306/tcp --permanent
firewall-cmd --add-port=9200/tcp --permanent
firewall-cmd --reload

# MYSQL Config Settings
cat << EOF > /etc/my.cnf.d/server.cnf
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
wsrep_cluster_address          = "gcomm://$GALERA_DB_NODE_LIST"
wsrep_cluster_name             = '$GALERA_CLUSTER_NAME'
wsrep_node_address             = '$GALERA_NODE_IP'
wsrep_node_name                = '$GALERA_NODE_NAME'

# MYISAM REPLICATION SUPPORT #
wsrep_replicate_myisam         = ON
EOF

if [ "$GALERA_DB_ROLE" == "master" ];
then
    echo "starting master"
    galera_new_cluster
else
    echo "starting slave"
    systemctl start mariadb
fi