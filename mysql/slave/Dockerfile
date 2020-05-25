FROM mysql:5.7
MAINTAINER newrain 

ENV MYSQL_ALLOW_EMPTY_PASSWORD yes
COPY conf.sh /mysql/conf.sh
COPY privileges.sql /mysql/privileges.sql
COPY replication.cnf /etc/mysql/mysql.conf.d
CMD ["sh", "/mysql/conf.sh"]
