FROM ubuntu:22.04 AS base


# ==================================================================================================

FROM base AS builder


WORKDIR /tmp
RUN apt update
RUN apt install -y git curl patch
RUN git clone https://github.com/chobits/ngx_http_proxy_connect_module.git

RUN curl -O "http://nginx.org/download/nginx-1.9.2.tar.gz"

RUN tar -xzvf nginx-1.9.2.tar.gz 

RUN cd nginx-1.9.2/
patch -p1 < ./ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_102101.patch

RUN ./configure --add-module=./ngx_http_proxy_connect_module

RUN make && make install



RUN apt-get install openssl-dev zlib-dev



# ==================================================================================================

FROM base

COPY --from=builder /usr/local/nginx /usr/local/nginx
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY ./nginx.conf /usr/local/nginx/conf/nginx.conf

CMD ["/bin/sh", "-c", "nginx -V; nginx -t; nginx"]
