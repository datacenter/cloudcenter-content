#!/bin/bash -x
. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh


sed -e 's/database_name_here/wordpress/' \
-e 's/username_here/root/' \
-e 's/password_here/welcome2cliqr/' \
-e 's/localhost/'$CliqrTier_mysql_1_IP'/' \
-e 's/utf8/utf8mb4/' \
/var/www/wp-config-sample.php > /var/www/wp-config.php