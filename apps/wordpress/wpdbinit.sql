SET GLOBAL log_output = "FILE";
SET GLOBAL general_log_file = "/var/tmp/mysql.log";
SET GLOBAL general_log = 'ON';

CREATE DATABASE wordpress;

GRANT ALL PRIVILEGES ON wordpress.* TO wordpress@'%' IDENTIFIED BY 'welcome2cliqr';

FLUSH PRIVILEGES;
