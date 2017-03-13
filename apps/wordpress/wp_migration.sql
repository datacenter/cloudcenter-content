use wordpress;
update wp_options set option_value = 'http://%APP_SERVER_IP%/wordpress' where option_name = 'siteurl';
update wp_options set option_value = 'http://%APP_SERVER_IP%/wordpress' where option_name = 'home';