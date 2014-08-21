hidocker
========

Hipache + Redis inside of Docker

# Deploying
Build the hidocker container.
```shell
git clone https://github.com/evanscottgray/hidocker && cd hidocker && docker build --rm=true --tag="evanscottgray/hidocker" .`
```

Start the hidocker container.
```shell
docker run -d -p 80:80 -p 6379:6379 evanscottgray/hidocker
```

Push a frontend with redis-cli.
```shell
redis-cli -h 127.0.0.1 -p 49159 rpush frontend:app1.website.com app1
redis-cli -h 127.0.0.1 -p 49159 rpush frontend:app1.website.com  http://$ip_of_app_1_node_1:$port_of_app_1_node_1
```

Keep in mind that Hipache acts as a Load Balancer as well as a Reverse Proxy, so you can add multiple nodes to one frontend.
```
redis-cli -h 127.0.0.1 -p 49159 rpush frontend:app1.website.com  http://$ip_of_app_1_node_2:$port_of_app_1_node_2
redis-cli -h 127.0.0.1 -p 49159 rpush frontend:app1.website.com  http://$ip_of_app_1_node_3:$port_of_app_1_node_3
redis-cli -h 127.0.0.1 -p 49159 rpush frontend:app1.website.com  http://$ip_of_app_1_node_4:$port_of_app_1_node_4
```

# DNS Stuff
Hipache works very well when you have a Domain or a Subdomain dedicated to it. If I have website.com and I want to host applications on *.website.com then I need to do two things.

1. Create a DNS A record that points website.com to the Public IP of the server running this container.
2. Create a DNS CNAME record to point *.website.com to website.com

The same applies if you have staging.otherwebsite.com and you want to host applications on *.staging.otherwebsite.com, simply create the A record pointing the Public IP of the server running Hipache to staging.otherwebsite.com and then CNAME *.staging.otherwebsite.com to staging.otherwebsite.com and BOOM you've got a new location to host apps.

# Caution
The default arguments in this README don't really provide any security of any sort, the redis port is wide open for anyone to edit and play with, and there are also no passwords on the database.

For a real 'production' deploy of Hipache, you should probably look into configuring SSL in the config.json and also locking down access to the Redis instance by not publishing the port publicly.

# Sample SSL Config

Here is a sample configuration for adding SSL support, you'll obviously have to rebuild the container as well as change out a few variables if you want to run this way.

```json
{
    "server": {
        "accessLog": "/var/log/hipache_access.log",
        "port": 80,
        "workers": 5,
        "maxSockets": 100,
        "deadBackendTTL": 30,
        "address": [
            "0.0.0.0"
        ],
        "address6": [
            "::1"
        ],
        "https": {
            "port": 443,
            "key": "/root/website.com.key",
            "cert": "/root/website.com.crt"
        }
    },
    "redisHost": "127.0.0.1",
    "redisPort": 6379,
    "redisDatabase": 0
}
```
#### Quick SSL Overview

To generate your own SSL key/certificate, you can use the following sequence of commands replacing arguments where appropriate:
```shell
openssl req -new -key website.com.key -out website.com.csr
openssl genrsa -des3 -passout pass:x -out website.com.pass.key 2048
openssl rsa -passin pass:x -in website.com.pass.key -out website.com.key
openssl req -new -key website.com.key -out website.com.csr
openssl x509 -req -days 365 -in website.com.csr -signkey website.com.key -out website.com.crt
```
You'll then need to add these to the container by modifying the Dockerfile.


