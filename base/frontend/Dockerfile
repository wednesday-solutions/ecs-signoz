FROM signoz/frontend:${DOCKER_TAG:-0.18.1}

COPY ./common/nginx-config.conf /etc/nginx/conf.d/default.conf
RUN apk add bash
COPY ./nginxReload.sh /nginxReload.sh
COPY ./start.sh ./start.sh
RUN chmod +x /nginxReload.sh
RUN chmod +x ./start.sh
RUN apk add openrc
RUN echo "* * * * *   /bin/bash /nginxReload.sh" >> /var/spool/cron/crontabs/root


ENTRYPOINT ["./start.sh" ]
CMD [ "crond -f -l 2 -L /dev/stdout" ]


EXPOSE 3301