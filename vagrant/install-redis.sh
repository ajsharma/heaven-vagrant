#!/bin/sh

####
# This script can be used to install redis
####
cd /tmp
wget http://download.redis.io/releases/redis-2.8.19.tar.gz
tar xzf redis-2.8.19.tar.gz
cd redis-2.8.19
make
