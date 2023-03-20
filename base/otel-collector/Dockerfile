FROM signoz/signoz-otel-collector:${OTELCOL_TAG:-0.66.6}



ENV OTEL_RESOURCE_ATTRIBUTES=host.name=signoz-host,os.type=linux
ENV DOCKER_MULTI_NODE_CLUSTER=false
ENV LOW_CARDINAL_EXCEPTION_GROUPING=false

COPY  ./otel-collector-config.yaml /etc/otel-collector-config.yaml
USER root
RUN apk add --no-cache curl



CMD [ "--config=/etc/otel-collector-config.yaml" ]

EXPOSE 4317
EXPOSE 4318
EXPOSE 8889
