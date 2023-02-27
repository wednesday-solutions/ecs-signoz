From signoz/query-service:${DOCKER_TAG:-0.16.0}


ENV ClickHouseUrl=tcp://ip-10-1-50-67.ap-southeast-1.compute.internal:9000/?database=signoz_traces
ENV ALERTMANAGER_API_PREFIX=http://alert-svc.dev.signoz-app.local:9093/api/
ENV SIGNOZ_LOCAL_DB_PATH=/var/lib/signoz/signoz.db
ENV DASHBOARDS_PATH=/root/config/dashboards
ENV STORAGE=clickhouse
ENV GODEBUG=netdns=go
ENV TELEMETRY_ENABLED=true
ENV DEPLOYMENT_TYPE=docker-standalone-amd


Copy ./prometheus.yml /root/config/prometheus.yml
COPY ./dashboards /root/config/dashboards
COPY ./data/signoz/ /var/lib/signoz/
CMD ["-config=/root/config/prometheus.yml"]


EXPOSE 8080
EXPOSE 8085
