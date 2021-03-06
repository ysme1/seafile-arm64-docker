#!/bin/sh

set -x

if [ -z "$TRAVIS" ]; then
	sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
fi

apk update

apk add --no-progress \
	vim htop net-tools psmisc busybox-extras bash openssl \
	wget curl git tzdata nginx libmemcached libxcb libjpeg \
	zlib-dev python3 py3-pip py3-setuptools memcached tiff \
	py3-click py3-termcolor py3-jinja2 py3-lxml py3-sqlalchemy \
	libwebp sqlite freetype

rm -rf /var/cache/apk/*

ln -sf /usr/bin/python3 /usr/bin/python

if [ -z "$TRAVIS" ]; then
	python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple pip -U
	python3 -m pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
else
	python3 -m pip install --upgrade pip
fi

python3 -m pip install colorlog pymysql

rm -r /root/.cache/pip

cp /scripts/create_data_links.sh /etc/cont-init.d/01_create_data_links.sh

sed -i '/^user/d' /services/nginx.conf

mkdir -p /etc/nginx/sites-enabled /etc/nginx/conf.d/ /run/nginx/ && \
	rm -f /etc/nginx/sites-enabled/* /etc/nginx/conf.d/* && \
	mv /services/nginx.conf /etc/nginx/nginx.conf

mkdir -p /etc/services.d/nginx && \
	mv /services/nginx.sh /etc/services.d/nginx/run

mkdir -p /etc/services.d/memcached && \
	mv /services/memcached.sh /etc/services.d/memcached/run

chmod +x /etc/cont-init.d/*

