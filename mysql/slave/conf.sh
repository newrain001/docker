#!/bin/bash

set -e

echo 'start mysql...'
service mysql start

echo 'setting password...'
sed -i 's/MYSQLROOTPASSWORD/'$MYSQL_ROOT_PASSWORD'/' /mysql/privileges.sql
sed -i 's/MYSQLREPLICATIONUSER/'$MYSQL_REPLICATION_USER'/' /mysql/privileges.sql
sed -i 's/MYSQLMASTERSERVICEHOST/'$MYSQL_MASTER_SERVICE_HOST'/' /mysql/privileges.sql
sed -i 's/MYSQLREPLICATIONPASSWORD/'$MYSQL_REPLICATION_PASSWORD'/' /mysql/privileges.sql

mysql < /mysql/privileges.sql
echo "ready ok"

tail -f /dev/null
