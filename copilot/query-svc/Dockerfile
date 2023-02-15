From signoz/query-service:${DOCKER_TAG:-0.16.0}


ENV ClickHouseUrl=tcp://ec2-3-110-134-148.ap-south-1.compute.amazonaws.com:9000/?database=signoz_traces
ENV ALERTMANAGER_API_PREFIX=http://signo-Publi-1J2RGQZ5JX274-a57dd3fec24ba410.elb.ap-southeast-1.amazonaws.com:9093/api/
ENV SIGNOZ_LOCAL_DB_PATH=/var/lib/signoz/signoz.db
ENV DASHBOARDS_PATH=/root/config/dashboards
ENV STORAGE=clickhouse
ENV GODEBUG=netdns=go
ENV TELEMETRY_ENABLED=true
ENV DEPLOYMENT_TYPE=docker-standalone-amd


Copy ./prometheus.yml /root/config/prometheus.yml
COPY ./dashboards /root/config/dashboards
COPY ./data/signoz/ /var/lib/signoz/



EXPOSE 8080
EXPOSE 8085
