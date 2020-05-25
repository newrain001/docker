use mysql;
set password for root@'localhost' = password('MYSQLROOTPASSWORD');
flush privileges;
CHANGE MASTER TO master_host='MYSQLMASTERSERVICEHOST', master_user='MYSQLREPLICATIONUSER', master_password='MYSQLREPLICATIONPASSWORD' ;
START SLAVE;
