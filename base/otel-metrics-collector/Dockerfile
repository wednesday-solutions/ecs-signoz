FROM signoz/signoz-otel-collector:${OTELCOL_TAG:-0.66.7}

CMD ["--config=/etc/otel-collector-metrics-config.yaml"]



COPY  ./otel-collector-metrics-config.yaml /etc/otel-collector-metrics-config.yaml


    