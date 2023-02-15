#!/bin/bash

[ -z "$1" ] && echo "No app name argument supplied" && exit 1

[ -z "$2" ] && echo "No env name argument is provided" && exit 1

[ -z "$3" ] && echo "No otel collector service name argument supplied" && exit 1

[ -z "$4" ] && echo "No query server service name argument supplied" && exit 1

[ -z "$5" ] && echo "No alert manager service name argument supplied" && exit 1

[ -z "$6" ] && echo "No frontend service name argument supplied" && exit 1



echo "application name $1-app"

echo "environment name $2"

echo "otel collector name $3-svc"

echo "otel collector metrics $2-metrics-svc"

echo "query service name $4-svc"

echo "alert manager service name $5-svc"

echo "frontend $6-svc"

# echo "environment name $6"

AppName="$1-app"
OtelSvcName="$3-svc"
OtelMetricsSvcName="$3-metrics-svc"
QuerySvcName="$4-svc"
AlertManagerSvcName="$5-svc"
FrontendSvcName="$6-svc"


OtelServiceAddress="${OtelSvcName}.${2}.${AppName}.local:4317"
OtelServiceAddressInternal="${OtelSvcName}.${2}.${AppName}.local:8889"
QueryServiceAddress="${QuerySvcName}.${2}.${AppName}.local:8080"
QueryServiceAddressInternal="${QuerySvcName}.${2}.${AppName}.local:8085"
AlertManagerServiceAddress="${AlertManagerSvcName}.${2}.${AppName}.local:9093"


mkdir -p copilot/$OtelSvcName
cp base/otel-collector/manifest.yml copilot/$OtelSvcName/manifest.yml
sed -i -r "s/some-otel-svc-name/$OtelSvcName/g" copilot/$OtelSvcName/manifest.yml
rm copilot/$OtelSvcName/manifest.yml-r


mkdir -p copilot/$OtelMetricsSvcName
cp base/otel-metrics-collector/manifest.yml copilot/$OtelMetricsSvcName/manifest.yml
cp base/otel-metrics-collector/otel-collector-config.yaml copilot/$OtelMetricsSvcName/otel-collector-config.yaml
cp base/otel-metrics-collector/Dockerfile copilot/$OtelMetricsSvcName/Dockerfile

sed -i -r "s/some-otel-metrics-svc-name/OtelServiceAddressInternal/g" copilot/$OtelMetricsSvcName/manifest.yml
sed -i -r "s/otel-collector-url/$OtelMetricsSvcName/g" copilot/$OtelMetricsSvcName/otel-collector-config.yaml
rm copilot/$OtelMetricsSvcName/manifest.yml-r
rm otel-collector-config.yaml-r


mkdir -p copilot/$QuerySvcName
cp base/query-service/manifest.yml copilot/$QuerySvcName/manifest.yml
cp base/query-service/dashboards copilot/$QuerySvcName/dashboards
cp base/query-service/data copilot/$QuerySvcName/data
cp base/query-service/prometheus.yml copilot/$QuerySvcName/prometheus.yml
cp base/query-service/Dockerfile copilot/$QuerySvcName/Dockerfile

sed -i -r "s/some-query-service/$QuerySvcName/g" copilot/$QuerySvcName/manifest.yml
sed -i -r "s/some-alert-manager-url/$AlertManagerServiceAddress/g" copilot/$QuerySvcName/prometheus.yml
rm copilot/$QuerySvcName/manifest.yml-r


mkdir -p copilot/$AlertManagerSvcName
cp base/query-service/manifest.yml copilot/$QuerySvcName/manifest.yml
cp base/query-service/data copilot/$QuerySvcName/data
cp base/query-service/Dockerfile copilot/$QuerySvcName/Dockerfile


sed -i -r "s/some-alert-service/$AlertManagerSvcName/g" copilot/$AlertManagerSvcName/manifest.yml
sed -i -r "s/some-alert-manager-url/$QueryServiceAddressInternal/g" copilot/$AlertManagerSvcName/manifest.yml
rm copilot/$AlertManagerSvcName/manifest.yml-r

mkdir -p copilot/$FrontendSvcName
cp base/frontend/manifest.yml copilot/$FrontendSvcName/manifest.yml
cp base/frontend/common copilot/$FrontendSvcName/common
cp base/frontend/Dockerfile copilot/$FrontendSvcName/Dockerfile

sed -i -r "s/some-alert-manager-url/$AlertManagerServiceAddress/g" copilot/$AlertManagerSvcName/common/nginx-config.conf
sed -i -r "s/some-query-service/$AQueryServiceAddress/g" copilot/$AlertManagerSvcName/common/nginx-config.conf

copilot app init $AppName

copilot init -a "$AppName" -t "Backend Service" -n "$OtelSvcName"
copilot env init --name $2 --profile default --default-config
copilot env deploy --name $2

copilot deploy --name "$OtelSvcName" -e "$2"


