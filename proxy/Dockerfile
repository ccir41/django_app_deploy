FROM nginxinc/nginx-unprivileged:1-alpine
LABEL maintainer="shishirsubedi.com"

COPY ./default.conf.tpl /etc/nginx/default.conf.tpl
COPY ./uwsgi_params /etc/nginx/uwsgi_params
COPY ./entrypoint.sh /entrypoint.sh

ENV LISTEN_PORT=8000
ENV APP_HOST=app
ENV APP_PORT=9000

USER root

RUN mkdir -p /vol/static && \
    mkdir -p /vol/media && \
    chmod 755 /vol/static && \
    chmod 755 /vol/media && \
    touch /etc/nginx/conf.d/default.conf && \
    chown nginx:nginx /etc/nginx/conf.d/default.conf && \
    chmod +x /entrypoint.sh

VOLUME ["/vol/static", "/vol/media"]

USER nginx

CMD ["/entrypoint.sh"]
