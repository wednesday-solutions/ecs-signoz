FROM golang:1.19-alpine

WORKDIR /app

COPY go.mod ./


COPY *.go ./
RUN go mod tidy
ENV SERVICE_NAME=GIN-APP
ENV OTEL_EXPORTER_OTLP_ENDPOINT=some-otel-endpoint
ENV INSECURE_MODE=true
RUN go build -o /go-docker-demo

EXPOSE 8090

CMD [ "/go-docker-demo" ]




