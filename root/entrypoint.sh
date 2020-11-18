#!/bin/sh

set -e

sed "s@__NGINX_PROXY_PASS__@${NGINX_PROXY_PASS:-http://localhost:8080}@" -i /etc/nginx/nginx.conf

if [[ ${MAXMIND_LICENSE} ]]; then
  # GeoLite2-City.mmdb might also be interesting..?
  echo -e "MAXMINDDB_LICENSE_KEY=\"${MAXMIND_LICENSE}\"" > /etc/conf.d/libmaxminddb
  /etc/periodic/weekly/libmaxminddb
fi

if [ "$1" = "nginx" ]; then
    exec /usr/sbin/nginx
fi

exec "$@"
