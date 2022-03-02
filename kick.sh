#!/usr/bin/env bash

#
# Copyright (c) 2022. Alexandr Kosarev, @kosarev.by
#

unzip -o /var/tmp/backup.zip -d /var/www/html/

cd /var/www/html/
chown -R www-data:www-data .

sed -i "s/\$user = '.*'/\$user = '${DBUSER}'/" configuration.php
sed -i "s/\$password = '.*'/\$password = '${DBPASS}'/" configuration.php
sed -i "s/\$db = '.*'/\$db = '${DB}'/" configuration.php
sed -i "s/\$host = '.*'/\$host = 'mysql'/" configuration.php
sed -i "s/\$dbtype = 'mysql'/\$dbtype = 'mysqli'/" configuration.php
sed -i "s/\$dbprefix = '.*'/\$dbprefix = '${DBPREFIX}'/" configuration.php
sed -i "s/\$tmp_path = '.*'/\$tmp_path = '\/var\/www\/tmp'/" configuration.php
sed -i "s/\$log_path = '.*'/\$log_path = '\/var\/www\/logs'/" configuration.php
sed -i "s/\$cache_handler = '.*'/\$cache_handler = ''/" configuration.php

echo "DROP DATABASE IF EXISTS ${DB};" > site.sql
echo "DROP USER IF EXISTS ${DBUSER};" >> site.sql
echo "CREATE DATABASE IF EXISTS ${DB};" >> site.sql
echo "CREATE USER '${DBUSER}'@'%' IDENTIFIED BY '${DBPASS}';" >> site.sql
echo "GRANT ALL ON ${DB}.* TO '${DBUSER}'@'%';" >> site.sql
echo "USE ${DB};" >> site.sql
cat installation/sql/site.sql >> site.sql
rm -rf installation/sql/site.sql
ls -v installation/sql/site.s* | xargs cat >> site.sql
sed -i "s/#__/${DBPREFIX}/g" site.sql
cat site.sql | mysql -u root --password=$ROOTPASS -h mysql
rm -rf site.sql

## update user password
JPASS="$(echo -n "$JUSERPASS" | md5sum | awk '{ print $1 }' )"
echo "UPDATE \`${DBPREFIX}users\` SET \`password\` = '${JPASS}' WHERE \`username\` ='${JUSERNAME}';" | mysql -u $DBUSER --password=$DBPASS -h mysql $DB
rm -rf installation/
