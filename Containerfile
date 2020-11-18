FROM alpine:3.12

EXPOSE 8080

RUN apk update \
    && apk add git pcre-dev libxml2-dev libmaxminddb \
    && apk add --no-cache --virtual .build-deps linux-headers make libtool autoconf automake g++ curl-dev libmaxminddb-dev \
    && mkdir /build \
    && cd /build \
    && git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity \
    && cd ModSecurity \
    && git submodule init \
    && git submodule update \
    && ./build.sh \
    && ./configure \
    && make && make install \
    && cd /build \
    && git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git \
    && wget http://nginx.org/download/nginx-1.18.0.tar.gz \
    && tar -zxvf nginx-1.18.0.tar.gz \
    && cd nginx-1.18.0 \
    && ./configure --prefix=/etc/nginx --conf-path=/etc/nginx/nginx.conf --sbin-path=/usr/sbin/nginx --http-client-body-temp-path=/tmp/nginx/client_body_temp --http-proxy-temp-path=/tmp/nginx/proxy_temp --http-log-path=/dev/stdout --error-log-path=/dev/stderr --pid-path=/etc/nginx/nginx.pid --with-debug --with-http_ssl_module --with-compat --add-module=/build/ModSecurity-nginx --without-http_access_module --without-http_auth_basic_module --without-http_autoindex_module --without-http_empty_gif_module --without-http_fastcgi_module --without-http_referer_module --without-http_memcached_module --without-http_scgi_module --without-http_split_clients_module --without-http_ssi_module --without-http_uwsgi_module \
    && make && make install \
    && cd /build \
    && git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/src/owasp-modsecurity-crs \
    && cp -R /usr/src/owasp-modsecurity-crs/rules/ /etc/nginx/ \
    && mv /etc/nginx/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example  /etc/nginx/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf \
    && mv /etc/nginx/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf.example  /etc/nginx/rules/RESPONSE-999-EXCLUSION-RULES-AFTER-CRS.conf \
    && mkdir /etc/nginx/ModSecurity \
    && mv /build/ModSecurity/unicode.mapping /etc/nginx//ModSecurity/unicode.mapping \
    && apk del .build-deps && cd / && rm -rf /build \
    && adduser --uid 1000 --disabled-password nginx

COPY root /

ENTRYPOINT ["/entrypoint.sh"]
CMD ["nginx"]
