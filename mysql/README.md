### mysql 主从复制
|使用docker容器进行主从复制
- 1、执行master中dockerfile,创建镜像
```
docker build -t imagename ./master
# 创建容器
docker run  --name master -p 3306:3306 -e MYSQL_ROOT_PASSWORD="123456" -e MYSQL_REPLICATION_USER="repl"  -e MYSQL_REPLICATION_PASSWORD="123456"  -d imagename

```

- 2、执行slave中dockerfile,创建镜像
```
docker build -t imagename ./slave
# 找到ip地址
docker inspect master |grep IPAddr 
docker run  --name slave -p 3307:3306 -e MYSQL_ROOT_PASSWORD="123456" -e MYSQL_MASTER_SERVICE_HOST="172.17.0.2" -e MYSQL_REPLICATION_USER='repl' -e MYSQL_REPLICATION_PASSWORD="123456"   -d imagename

```

也可以采用docker-compose.yml进行创建
```
docker-compose up -d
```
