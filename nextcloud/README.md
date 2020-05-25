# NEXTCLOUD+ONLYOFFICE 

- 云服务解决及在线办公系统



### 一、docker 服务清理及安装

```
关闭防火墙，selinux

yum remove docker \
docker-client \
docker-client-latest \
docker-common \
docker-latest \
docker-latest-logrotate \
docker-logrotate \
docker-selinux \
docker-engine-selinux \
docker-engine


安装docker所需要的依赖环境
yum install -y yum-utils device-mapper-persistent-data lvm2
#3.安装docker仓库
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
#4.安装docker
yum install docker-ce -y
#5.启动docker
systemctl start docker


```

### 二、docker-compose-yml

```
下方文件中：
      MYSQL_ROOT_PASSWORD: 123456
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      MYSQL_PASSWORD: nextcloud123
      ports
均可修改
```



```dockerfile
version: '3'
services:
  web:
    hostname: web
    image: nginx
    ports:
      - 80:80
    networks:
      - cloud_net
    restart: always
    volumes:
      - ./nextcloud:/var/www/html
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
    depends_on:
      - app

  app:
    hostname: app
    image: nextcloud:18.0.3-fpm-alpine
    restart: always
    networks:
      - cloud_net
    volumes:
      - ./nextcloud:/var/www/html

  db:
    hostname: db
    image: mariadb
    restart: always
    networks:
      - cloud_net
    volumes:
      - ./db/data:/var/lib/mysql
    command: --character-set-server=utf8
    environment:
      MYSQL_ROOT_PASSWORD: 123456
      MYSQL_DATABASE: nextcloud
      MYSQL_USER: nextcloud
      MYSQL_PASSWORD: nextcloud123

  onlyoffice:
    hostname: onlyoffice
    image: onlyoffice/documentserver
    restart: always
    ports:
      - 6060:80
    networks:
      - cloud_net

networks:
  cloud_net:

```

### 三、nginx file

```nginx
user  www-data;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    set_real_ip_from  10.0.0.0/8;
    set_real_ip_from  172.16.0.0/12;
    set_real_ip_from  192.168.0.0/16;
    real_ip_header    X-Real-IP;

    #gzip  on;

    upstream php-handler {
        server app:9000;
    }

    server {
        listen 80;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header X-Robots-Tag none;
        add_header X-Download-Options noopen;
        add_header X-Permitted-Cross-Domain-Policies none;
        add_header Referrer-Policy no-referrer;

        root /var/www/html;

        location = /robots.txt {
            allow all;
            log_not_found off;
            access_log off;
        }

        location = /.well-known/carddav {
            return 301 $scheme://$host/remote.php/dav;
        }
        location = /.well-known/caldav {
            return 301 $scheme://$host/remote.php/dav;
        }

        # set max upload size
        client_max_body_size 10G;
        fastcgi_buffers 64 4K;

        # Enable gzip but do not remove ETag headers
        gzip on;
        gzip_vary on;
        gzip_comp_level 4;
        gzip_min_length 256;
        gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
        gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;

        location / {
            rewrite ^ /index.php$request_uri;
        }

        location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)/ {
            deny all;
        }
        location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console) {
            deny all;
        }

        location ~ ^/(?:index|remote|public|cron|core/ajax/update|status|ocs/v[12]|updater/.+|ocs-provider/.+)\.php(?:$|/) {
            fastcgi_split_path_info ^(.+\.php)(/.*)$;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            fastcgi_param PATH_INFO $fastcgi_path_info;
            # fastcgi_param HTTPS on;
            #Avoid sending the security headers twice
            fastcgi_param modHeadersAvailable true;
            fastcgi_param front_controller_active true;
            fastcgi_pass php-handler;
            fastcgi_intercept_errors on;
            fastcgi_request_buffering off;
        }

        location ~ ^/(?:updater|ocs-provider)(?:$|/) {
            try_files $uri/ =404;
            index index.php;
        }

        # Adding the cache control header for js and css files
        # Make sure it is BELOW the PHP block
        location ~ \.(?:css|js|woff|svg|gif)$ {
            try_files $uri /index.php$request_uri;
            add_header Cache-Control "public, max-age=15778463";
           
            add_header X-Content-Type-Options nosniff;
            add_header X-XSS-Protection "1; mode=block";
            add_header X-Robots-Tag none;
            add_header X-Download-Options noopen;
            add_header X-Permitted-Cross-Domain-Policies none;
            add_header Referrer-Policy no-referrer;

            # Optional: Don't log access to assets
            access_log off;
        }

        location ~ \.(?:png|html|ttf|ico|jpg|jpeg)$ {
            try_files $uri /index.php$request_uri;
            # Optional: Don't log access to other assets
            access_log off;
        }
    }

}


```



### 四、安装

- 目录结构

- ```
  [root@iZ8vbh58r0kcasrljfgu3jZ ~]# tree .
  .
  └── nextcloud
      ├── docker-compose.yml
      └── nginx.conf
  
  ```

- ```
  运行安装
  docker-compose up -d
  注： 如果安装太慢，可以配置docker 加速器，如果之前已经有下载了一部分，删除 /var/lib/docker/* 
  
  设置加速器
  sudo mkdir -p /etc/docker
  sudo tee /etc/docker/daemon.json <<-'EOF'
  {
    "registry-mirrors": ["https://pilvpemn.mirror.aliyuncs.com"]
  }
  EOF
  sudo systemctl daemon-reload
  sudo systemctl restart docker
  ```

  ![](https://i.loli.net/2020/04/17/tUEaG9kArYOcKVT.png)

- ```
  pull镜像完成后
  docker-compose ps # 查看容器启动状态
  [root@iZ8vbh58r0kcasrljfgu3jZ nextcloud]# docker ps -a
  CONTAINER ID        IMAGE                         COMMAND                  CREATED             STATUS              PORTS                           NAMES
  f0502eda6c65        nginx                         "nginx -g 'daemon of…"   8 seconds ago       Up 6 seconds        0.0.0.0:80->80/tcp              nextcloud_web_1
  c5b2fd2f3db4        nextcloud:18.0.3-fpm-alpine   "/entrypoint.sh php-…"   10 seconds ago      Up 7 seconds        9000/tcp                        nextcloud_app_1
  63610bf46fc3        mariadb                       "docker-entrypoint.s…"   10 seconds ago      Up 7 seconds        3306/tcp                        nextcloud_db_1
  be9c5bad6288        onlyoffice/documentserver     "/bin/sh -c /app/ds/…"   10 seconds ago      Up 5 seconds        443/tcp, 0.0.0.0:6060->80/tcp   nextcloud_onlyoffice_1
  
  访问 ip:80
  ```

  ![](https://i.loli.net/2020/04/17/H9yoOz4LZMKB38b.png)

![image-20200417012517691](/image-20200417012517691.png)



### 五、添加ONLYOFFICE

等待安装完成后，进入到nextcloud

选择右上角加号--》应用--》Organization --》ONLYOFFICE (如果没有反应，看下面)

- 服务器中进入最开始创建镜像的目录

- ```
  [root@iZ8vbh58r0kcasrljfgu3jZ nextcloud]# ls 
  db  docker-compose.yml  nextcloud  nginx.conf
  [root@iZ8vbh58r0kcasrljfgu3jZ nextcloud]# cd nextcloud/
  [root@iZ8vbh58r0kcasrljfgu3jZ nextcloud]# cd apps/
  [root@iZ8vbh58r0kcasrljfgu3jZ apps]# git clone https://github.com/ONLYOFFICE/onlyoffice-nextcloud.git onlyoffice
  正克隆到 'onlyoffice'...
  remote: Enumerating objects: 3, done.
  remote: Counting objects: 100% (3/3), done.
  remote: Compressing objects: 100% (3/3), done.
  remote: Total 3277 (delta 0), reused 0 (delta 0), pack-reused 3274
  接收对象中: 100% (3277/3277), 2.11 MiB | 16.00 KiB/s, done.
  处理 delta 中: 100% (2155/2155), done.
  
  下载完成后，进入已禁用的应用目录，刷新后，就可以看到onlyoffice，然后把它启用
  ```

  [![tiKYid.png](https://s1.ax1x.com/2020/05/26/tiKYid.png)](https://imgchr.com/i/tiKYid)



- 在设置页面中，找到onlyoffice 进行如下配置
- ![tiKwsf.png](https://s1.ax1x.com/2020/05/26/tiKwsf.png)

- [![tiKsoQ.png](https://s1.ax1x.com/2020/05/26/tiKsoQ.png)](https://imgchr.com/i/tiKsoQ)

- ![tiK5eU.png](https://s1.ax1x.com/2020/05/26/tiK5eU.png)

- ![image-20200417013614781](./image/image-20200417013614781.png)



