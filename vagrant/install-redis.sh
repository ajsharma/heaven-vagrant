#!/bin/sh

####
# This script can be used to install redis
####

echo "Installing Redis"
cd /tmp
wget http://download.redis.io/releases/redis-2.8.19.tar.gz
cd /opt
tar xzf /tmp/redis-2.8.19.tar.gz
cd /opt/redis-2.8.19
make

echo "Redis installed"
echo "Run Redis with `sudo /opt/redis-2.8.19/src/redis-server"
