# evanscottgray/hidocker
#
# VERSION               0.0.1

from ubuntu
MAINTAINER Evan Gray <evan@evanscottgray.com>

RUN	echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN	apt-get -y update
RUN	apt-get -y install wget git redis-server supervisor
run	wget -O - http://nodejs.org/dist/v0.8.23/node-v0.8.23-linux-x64.tar.gz | tar -C /usr/local/ --strip-components=1 -zxv
RUN	npm install hipache -g
RUN	mkdir -p /var/log/supervisor
ADD	./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD	./config.json /usr/local/lib/node_modules/hipache/config/config.json

# Uncomment and fill in where appropriate.
# ADD	./something.com.crt /root/something.com.crt
# ADD	./something.com.key /root/something.com.key

EXPOSE	[ 80 , 443 , 6379 ]
CMD	["supervisord", "-n"]
