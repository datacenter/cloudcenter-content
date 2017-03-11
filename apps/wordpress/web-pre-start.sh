#!/bin/bash -x
exec > >(tee -a /var/tmp/web-pre-start_$$.log) 2>&1

. /usr/local/osmosix/etc/.osmosix.sh
. /usr/local/osmosix/etc/userenv
. /usr/local/osmosix/service/utils/cfgutil.sh

echo "Username: $(whoami)"
echo "Working Directory: $(pwd)"

sudo sed -e 's/database_name_here/wordpress/' \
-e 's/username_here/root/' \
-e 's/password_here/welcome2cliqr/' \
-e 's/localhost/'$CliqrTier_mysql_1_IP'/' \
-e 's/utf8/utf8mb4/' \
/var/www/wordpress/wp-config-sample.php > /var/www/wordpress/wp-config.php
