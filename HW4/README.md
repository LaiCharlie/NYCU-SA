## HW4

> My ID : 108

- [x] HTTP Server (90%)
    - [x] Virtual Hosts (3%)
    - [x] Common
        - [x] Hide Server Information (3%)
        - [x] HTTPS and PKI (12%)
        - [x] Access Control (3%)
        - [x] Normal Logging (8%)
        - [x] Verbose Logging (16%)
        - [x] Log Rotate (5%)
    - [x] file.{ID}.cs.nycu (20%)
    - [x] Database & adminer.{ID}.cs.nycu (20%)

> [!TIP]
> #### Ref:
> [dnsmasq1](https://www.uptimia.com/questions/how-to-create-wildcard-subdomains-with-dnsmasq)
> [dnsmasq2](https://sp.idv.tw/wp/index.php/2023/02/02/1722/)
> [Nginx SSL CA1](https://blog.gtwang.org/linux/nginx-create-and-install-ssl-certificate-on-ubuntu-linux/)
> [SSL CA2](https://www.humankode.com/ssl/create-a-selfsigned-certificate-for-nginx-in-5-minutes/)
> [nginx conf example](https://github.com/ChuEating1005/SA/blob/master/HW4/Web_Server/nginx.conf)
> [ngx stage](https://moonbingbing.gitbooks.io/openresty-best-practices/content/ngx_lua/phase.html)


> [!NOTE] 
> #### Install OpenResty on Ubuntu 24.04
> [Download Document](https://openresty.org/en/installation.html)
> - Step 1
> ```bash
> sudo systemctl disable nginx
> sudo systemctl stop nginx
> sudo apt-get -y install --no-install-recommends wget gnupg ca-certificates lsb-release
> wget -O - https://openresty.org/package/pubkey.gpg | sudo gpg --dearmor -o /usr/share/keyrings/openresty.gpg
> ```
> - Step 2
> - For `x86_64` or `amd64` systems:
> ```bash
> echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openresty.gpg] http://openresty.org/package/ubuntu $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/openresty.list > /dev/null
> ```
> 
> - Step 2
> - For `arm64` or `aarch64` systems:
> ```bash
> echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openresty.gpg] http://openresty.org/package/arm64/ubuntu $(lsb_release -sc) main" | > sudo tee /etc/apt/sources.list.d/openresty.list > /dev/null
> ```
> 
> - Step 3
> ```bash
> sudo apt-get update
> sudo apt-get -y install openresty
> systemctl restart openresty
> systemctl enable openresty
> systemctl status openresty
> ```
> 
> - Step 4
> ```bash
> vim /usr/local/openresty/nginx/conf/nginx.conf
> # write all the config into the new nginx.conf
> ```

## Virtual Host

### OpenResty
> Example
```bash
sudo vim /usr/local/openresty/nginx/conf/nginx.conf
# http {
#     server {
#         listen 80;
#         listen [::]:80;

#         server_name 108.cs.nycu;

#         return 301 https://$host$request_uri;
#     }
# }
```

> Check the configuration
```bash
sudo openresty -t
```

> Restart OpenResty
```bash
sudo systemctl restart openresty
```

> [!NOTE] 
> I use `OpenResty` to finish HW4

> ----

> wildcard subdomain

- Use `dnsmasq`
```bash
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
sudo apt install dnsmasq
sudo systemctl restart dnsmasq
sudo systemctl status dnsmasq
```

- Create `dnsmasq_resolv.conf`
```bash
cat /etc/dnsmasq_resolv.conf
nameserver 140.113.1.1
nameserver 8.8.8.8
```

```bash
sudo nano /etc/dnsmasq.conf
# resolv-file=/etc/dnsmasq_resolv.conf
# server=8.8.8.8
# address=/.108.cs.nycu/127.0.0.1
sudo systemctl restart dnsmasq
```

> ------

## Common

### Hide Server Information
> Close `server_tokens`
```bash
sudo vim /usr/local/openresty/nginx/conf/nginx.conf
# # add below line
# server_tokens off;
```

### HTTPS & PKI

> Create CA
```bash
# Set in your prefer path
sudo apt install openssl
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt -subj "/C=TW/ST=HsinChu/O=NYCU/CN=108.cs.nycu"
```

> Trust the CA
```bash
cp ca.crt /usr/local/share/ca-certificates
sudo update-ca-certificates
```
<!-- sudo dpkg-reconfigure ca-certificates -->

> Wildcard certificate
```bash
openssl genrsa -out server.key 4096
openssl req -new -key server.key -out server.csr -subj "/C=TW/ST=HsinChu/O=NYCU/CN=*.108.cs.nycu"
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 365 -sha256
```

> Redirect HTTP to HTTPS
> ex: `nasa.108.cs.nycu`
```bash
sudo vim /usr/local/openresty/nginx/conf/nginx.conf
# server {
#     listen 80;
#     listen [::]:80;
    
#     server_name nasa.108.cs.nycu;
#     return 301 https://$host$request_uri;
# }

# server {
#     listen 443 ssl;
#     listen [::]:443 ssl;
#     server_name nasa.108.cs.nycu;

#     ...

#     ssl_certificate /your/path/server.crt;
#     ssl_certificate_key /your/path/server.key;
     
#     ...
# }
```

> Enable HSTS
> ex: `nasa.108.cs.nycu`
```bash
sudo vim /usr/local/openresty/nginx/conf/nginx.conf
# server {
#     listen 443 ssl;
#     listen [::]:443 ssl;
#     server_name nasa.108.cs.nycu;

#     ...

#     add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    
#     ...
# }
```

> Test the HSTS / SSL certificate
```bash
curl -I -L https://108.cs.nycu
curl -v https://108.cs.nycu
```

### Access Control

> Install htpasswd
```bash
sudo apt install apache2-utils
```

> Create user `sa-admin`
```bash
sudo htpasswd -c /your/path/.htpasswd sa-admin
```

> Test the setting
```
curl -I https://nasa.108.cs.nycu
curl -I -u sa-admin:1011310811 https://nasa.108.cs.nycu
curl -I -u sa-admin:1011310811 --location-trusted http://nasa.108.cs.nycu
```

> --------

> Check the configuration
```bash
sudo openresty -t
```

> Restart Nginx
```bash
sudo systemctl restart openresty
```

> --------

### Normal Logging

> Conditional Logging
```bash
sudo vim nginx.conf
# map $http_user_agent $loggable {
#     default 1;
#     "~no-logging" 0;
# }
```

> Access log
```bash
sudo vim nginx.conf
# access_log /home/judge/webserver/log/access.log combined if=$loggable;
```

### Verbose Logging

> Logging
```bash
sudo vim /usr/local/openresty/nginx/conf/nginx.conf
# log_format test_encode 'STATUS: $web_status\t$encode_log';
# access_log  /home/judge/webserver/log/access.log test_encode if=$loggable;
# access_log  /home/judge/webserver/log/access.log combined    if=$loggable;

# body_filter_by_lua_block{
#     ...
# }

# lua_need_request_body on;
# log_by_lua_block {
#     ...
# }
```

### Log Rotate

> Install rotate tool
```bash
sudo apt update
sudo apt install logrotate
```

> link the `access.log`
```bash
sudo vim /usr/local/openresty/nginx/conf/nginx.conf
# Modify access.log to compressed.log
sudo ln -s compressed.log access.log
```

> Create config file
```bash
sudo vim /etc/logrotate.d/hw4_log
# rotate compressed.log
sudo logrotate -d /etc/logrotate.d/hw4_log
sudo logrotate -f /etc/logrotate.d/hw4_log
```

> -----

> Check the configuration
```bash
sudo openresty -t
```

> Restart OpenResty
```bash
sudo systemctl restart openresty
```


## Database

> Install PostgreSQL
```bash
sudo apt update
sudo apt install postgresql postgresql-client postgresql-contrib
systemctl status postgresql
```

> Set up user
```bash
sudo -u postgres psql
postgres=# CREATE USER root  WITH PASSWORD 'sahw4-108';
postgres=# ALTER  USER root  WITH SUPERUSER;
```

```bash
$ sudo -u postgres psql
postgres=# CREATE DATABASE judge;
postgres=# CREATE USER judge WITH PASSWORD 'your-password';
postgres=# ALTER  USER judge WITH SUPERUSER;
postgres=# GRANT  ALL PRIVILEGES ON DATABASE judge TO judge;
postgres=# \q
```

> Set up `PGPASSWORD` in `judge`
```bash
$ sudo vim ~/.profile
# Add line
# export PGPASSWORD="your-password"

$ . ~/.profile
```

> Set up `PGPASSWORD` in `root`
```bash
root@sa2024-108:~# vim .bashrc 
# Add line
# export PGPASSWORD="sahw4-108"
root@sa2024-108:~# source .bashrc 
```

> Test for `root` and `judge`
```bash
echo $PGPASSWORD
```

> Create database and table
```bash
$ psql

judge=# CREATE DATABASE "sa-hw4";
CREATE DATABASE

judge=# \c sa-hw4

sa-hw4=# CREATE TABLE "user" (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    age INTEGER,
    birthday DATE
);
```

> Database commands
```bash
# command lists
sa-hw4-# \?

# list tables
sa-hw4-# \d
            List of relations
 Schema |    Name     |   Type   | Owner 
--------+-------------+----------+-------
 public | user        | table    | judge
 public | user_id_seq | sequence | judge
(2 rows)

# list the structure of table `user`
sa-hw4-# \d user

sa-hw4-# INSERT INTO
  "user" (name, age, birthday)
  VALUES ('test_user', 22, '2002-11-13');
  
sa-hw4=# SELECT * FROM "user";
 id |   name    | age |  birthday  
----+-----------+-----+------------
  1 | test_user |  22 | 2002-11-13
  
sa-hw4=# DELETE FROM "user" WHERE id = 1;
```


## file.{ID}.cs.nycu

> Install Tools (on both machine)
```bash
sudo apt install python3-pip libpq-dev python3.12-venv
```

> Virtual Environment (on both machine)
```bash
root@sa2024-108:~# python3 -m venv fastapi-env
root@sa2024-108:~# source fastapi-env/bin/activate

(fastapi-env) root@sa2024-108:~# pip install asyncpg sqlalchemy databases fastapi uvicorn psycopg2 python-multipart

(fastapi-env) root@sa2024-108:/your/path# vim main.py
(fastapi-env) root@sa2024-108:/your/path# uvicorn main:app --host 192.168.108.1 --port 8080 --reload
```

> **Note**  : Use `deactivate` to leave Python virtual environment

> Distribute traffic (on `192.168.{ID}.1` only)
```bash
sudo vim /usr/local/openresty/nginx/conf/nginx.conf
# upstream backend_servers {
#     server 192.168.108.1:8080;
#     server 192.168.108.2:8080;
# }
# 
# server {
#     location / {
#         proxy_pass http://backend_servers;
#         proxy_set_header Host $host;
#         proxy_set_header X-Real-IP $remote_addr;
#         proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#     }
# }

sudo openresty -t
sudo systemctl restart openresty
```

> Setting Database
```bash
sudo vim /etc/postgresql/16/main/postgresql.conf
# Add the line:
# listen_addresses = '*'
sudo vim /etc/postgresql/16/main/pg_hba.conf
# Add the lines:
# host    all             all             192.168.108.1/32        trust
# host    all             all             192.168.108.2/32        trust
# Modify the line
# host    all             all             127.0.0.1/32            trust
systemctl restart postgresql
```

> NFS setting on `192.168.{ID}.2` (for `/upload` and `/file/{filename}`)
```bash
# watch the part NFS in the end of this note first
root@sa2024-108:/your/path# mkdir /your_upload_files_dir
root@sa2024-108:/your/path# chown nobody:nogroup /files
root@sa2024-108:/your/path# chmod 777 /your_upload_files_dir
root@sa2024-108:/your/path# vim /etc/exports
# Add line
# /your/path/your_upload_files_dir        192.168.108.0/24(rw,sync,no_subtree_check)
root@sa2024-108:/your/path# systemctl restart nfs-kernel-server
root@sa2024-108:/your/path# exportfs -rv
```

> NFS setting on `192.168.{ID}.1` (for `/upload` and `/file/{filename}`)
```bash
# watch the part NFS in the end of this note first
root@sa2024-108:/your/path# mkdir /your_upload_files_dir
root@sa2024-108:/your/path# sudo mount 192.168.108.2:/your/path/your_upload_files_dir /your/path/your_upload_files_dir
root@sa2024-108:/your/path# vim /etc/fstab
# Add line
# 192.168.108.2:/your/path/your_upload_files_dir    /your/path/your_upload_files_dir    nfs    defaults,auto    0 0
root@sa2024-108:/your/path# mount -a
```
    
## adminer.{ID}.cs.nycu
    
> Install tools
```bash
sudo apt update
sudo apt install php php-pgsql php-fpm
```

> Download admin.php
```bash
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php
sudo mv adminer-4.8.1.php /var/www/html/adminer.php
```

> Add permission
```bash
sudo vim /etc/postgresql/16/main/pg_hba.conf
# Add the line
# local   all             root                                    trust

systemctl restart postgresql
```

> Set up adminer.{ID}.cs.nycu
```bash
sudo vim /usr/local/openresty/nginx/conf/nginx.conf
# user www-data;
# 
# server {
#     location / {
#             root /var/www/html;
#             index adminer.php;
#     }
#     location ~ \.php$ {
#             include fastcgi_params;
#             fastcgi_pass unix:/run/php/php8.3-fpm.sock;
#             fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
#     }
# }
sudo openresty -t
sudo systemctl restart openresty
```

------

- [x] FireWall (20%)
    - [x] General rules (8%)
    - [x] SSH failed login (12%)

> ICMP rule
```bash
sudo iptables -A INPUT -p icmp --icmp-type echo-request -s 192.168.108.0/24 -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
sudo iptables -L
iptables-save
```

> HTTP rule
```bash
sudo vim /usr/local/openresty/nginx/conf/nginx.conf
# location / {
#     allow 127.0.0.1/32;
#     allow 10.113.{ID}.11/32;
#     allow 192.168.108.0/24;
#     deny all;
#     ...
# }
sudo openresty -t
sudo systemctl restart openresty
```

> SSH failed login (Fail2Ban)
```bash
sudo apt install fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo vim /etc/fail2ban/jail.local
# [sshd]
# enabled = true
# port    = ssh
# maxretry = 3
# bantime  = 1m
# findtime = 5m
sudo systemctl restart fail2ban
```


------

- [x] NFS (10%)
    - [x] Server (4%)
    - [x] Client (6%)

> Server set up
```bash
sudo apt update
sudo apt install nfs-kernel-server

sudo mkdir /data
sudo chown judge:judge /data
sudo chmod 755 /data

sudo vim /etc/exports
# Add line
# mount dir    allow ip        (mount config)
# /data        192.168.108.0/24(rw,sync,root_squash,no_subtree_check)

sudo systemctl restart nfs-kernel-server
sudo exportfs -rv
```

> Client set up
```bash
sudo apt update
sudo apt install nfs-common

sudo mkdir -p /net/data

sudo mount 192.168.108.2:/data /net/data
sudo vim /etc/fstab
# Add line
# 192.168.108.2:/data    /net/data     nfs     defaults,rw,auto     0 0

sudo mount -a
```

> Verify on server
```bash
sudo showmount -e
```

> Verify on client
```bash
df -h | grep /net/data
ls -l /net/data
```
