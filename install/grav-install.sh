#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Dries Dokter (ddt3)
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://getgrav.org/

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

PHP_VERSION="8.4" PHP_FPM="YES" PHP_APACHE="YES" PHP_MODULE="snmp,imap" setup_php
setup_composer
# Grav uses git clone to install, so we need to install git first
# Additionally, we need to install the addtional PHP extensions for Grav requires, which include yaml, memcache, and memcached.
$STD apt install --no-install-recommends -y git  php8.4-yaml php8.4-memcache php8.4-memcached
$STD composer create-project getgrav/grav /var/www/html/grav
$STD chown www-data:www-data /var/www/html/grav -R
$STD phpenmod curl ctype dom gd  mbstring  simplexml  xml zip yaml memcache memcached
#

msg_info "Installing Grav (Patience)"

msg_ok "Installed Grav"

msg_info "Setup Services"
cat <<EOF >/etc/apache2/sites-available/grav.conf
<VirtualHost *:80>
    ServerName yourdomain.com
    DocumentRoot /var/www/html/grav

    <Directory /var/www/html/grav>
        AllowOverride All
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOF
$STD a2ensite grav.conf
$STD a2dissite 000-default.conf
$STD a2enmod rewrite
# Because php modules are installed and enabled: restart apache2 to load the new modules
systemctl restart apache2
msg_ok "Created Services"
# Install Grav Admin Plugin
msg_info "Installing Grav Admin Plugin"
$STD cd /var/www/html/grav && sudo -u www-data php bin/gpm install admin -y
msg_ok "Installed Grav Admin Plugin"

motd_ssh
customize
cleanup_lxc
