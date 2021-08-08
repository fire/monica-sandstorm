#!/bin/bash

# When you change this file, you must take manual action. Read this doc:
# - https://docs.sandstorm.io/en/latest/vagrant-spk/customizing/#setupsh

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y nginx git postgresql-11
# patch /usr/local/etc/php-fpm.d/www.conf to not change uid/gid to www-data
sed --in-place='' \
        --expression='s/^listen.owner = www-data/;listen.owner = www-data/' \
        --expression='s/^listen.group = www-data/;listen.group = www-data/' \
        --expression='s/^user = www-data/;user = www-data/' \
        --expression='s/^group = www-data/;group = www-data/' \
        /usr/local/etc/php-fpm.d/www.conf
# patch /usr/local/etc/php-fpm.conf to not have a pidfile
sed --in-place='' \
        --expression='s/^pid =/;pid =/' \
        --expression='s/^;error_log =.*/error_log =\/var\/log\/php-fpm.log/' \
        /usr/local/etc/php-fpm.conf
# patch /usr/local/etc/php-fpm.conf to place the sock file in /var
sed --in-place='' \
       --expression='s/^listen = 127.0.0.1:9000/listen = \/var\/run\/php\/php-fpm.sock/' \
        /usr/local/etc/php-fpm.d/www.conf
# patch /usr/local/etc/php-fpm.d/www.conf to no clear environment variables
# so we can pass in SANDSTORM=1 to apps
sed --in-place='' \
        --expression='s/^;clear_env = no/clear_env=no/' \
        /usr/local/etc/php-fpm.d/www.conf

# Remove docker-specific config file that redirects stdio and forces the listen option to 9000
rm /usr/local/etc/php-fpm.d/docker.conf /usr/local/etc/php-fpm.d/zz-docker.conf
