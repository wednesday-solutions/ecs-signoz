FROM signoz/frontend:${DOCKER_TAG:-0.17.0}

COPY ./common/nginx-config.conf /etc/nginx/conf.d/default.conf

COPY ./nginxReload.sh /
RUN nohup ./nginxReload.sh &


EXPOSE 3301