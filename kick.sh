#!/usr/bin/env bash

#
# Copyright (c) 2022. Alexandr Kosarev, @kosarev.by
#

JUSERNAME="admin"
JUSERPASS="qweasd"
DB="joomla_364"
DBUSER="jdbuser"
DBPASS="dbupass"
DBPREFIX="prfx_"
ROOTPASS="qweasd"

## prepare
apt-get install unzip

unzip /var/tmp/backup.zip -d /var/www/html/

cd /var/www/html/
chown -R www-data:www-data .

sed -i "s/\$user = '.*?'/\$user = '${DBUSER}'/" configuration.php
sed -i "s/\$password = '.*?'/\$password = '${DBPASS}'/" configuration.php
sed -i "s/\$db = '.*?'/\$db = '${DB}'/" configuration.php
sed -i "s/\$dbprefix = '.*?'/\$dbprefix = '${DBPREFIX}'/" configuration.php
sed -i "s/\$tmp_path = '.*?'/\$tmp_path = '\/var\/www\/tmp'/" configuration.php
sed -i "s/\$log_path = '.*?'/\$log_path = '\/var\/www\/logs'/" configuration.php
sed -i "s/\$cache_handler = 'file'/\$cache_handler = ''/" configuration.php

mv installation/configuration.php-dist configuration.php
echo "CREATE DATABASE ${DB}" | mysql -u root --password=${ROOTPASS} -h mysql
echo "CREATE USER '${DBUSER}'@'%' IDENTIFIED BY '${DBPASS}';" | mysql -u root --password=${ROOTPASS} -h mysql
echo "GRANT ALL ON ${DB}.* TO '${DBUSER}'@'%';" | mysql -u root --password=${ROOTPASS} -h mysql
mv installation/sql/site.sql site.sql
cat installation/sql/site.s* >> site.sql
sed -i "s/#__/${DBPREFIX}/" site.sql
cat site.sql | mysql -u $DBUSER --password=$DBPASS -h mysql $DB
rm -rf site.sql

## update user password
JPASS="$(echo -n "$JUSERPASS" | md5sum | awk '{ print $1 }' )"
echo "UPDATE \`${DBPREFIX}users\` SET `password` = '${JPASS}' WHERE `username` ='${JUSERNAME}';" | mysql -u $DBUSER --password=$DBPASS -h mysql $DB
rm -rf installation/
