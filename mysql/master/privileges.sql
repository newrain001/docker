use mysql;
set password for root@'localhost' = password("MYSQLROOTPASSWORD");
grant all on *.* to "MYSQLREPLICATIONUSER"@'%' identified by "MYSQLREPLICATIONPASSWORD" with grant option;
flush privileges;
