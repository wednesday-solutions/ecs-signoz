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

path=".\/copilot\/"

mkdir -p copilot/$OtelSvcName
cp base/otel-collector/manifest.yml copilot/$OtelSvcName/manifest.yml
cp base/otel-collector/Dockerfile copilot/$OtelSvcName/Dockerfile
cp base/otel-collector/otel-collector-config.yaml copilot/$OtelSvcName/otel-collector-config.yaml
sed -i -r "s/some-otel-svc-name/$OtelSvcName/" copilot/$OtelSvcName/manifest.yml
p="${path}${OtelSvcName}"
sed -i -r "s/some-path/$p/" copilot/$OtelSvcName/manifest.yml
rm copilot/$OtelSvcName/manifest.yml-r



mkdir -p copilot/$OtelMetricsSvcName
cp base/otel-metrics-collector/manifest.yml copilot/$OtelMetricsSvcName/manifest.yml
cp base/otel-metrics-collector/otel-collector-metrics-config.yaml copilot/$OtelMetricsSvcName/otel-collector-metrics-config.yaml
cp base/otel-metrics-collector/Dockerfile copilot/$OtelMetricsSvcName/Dockerfile



sed -i -r "s/some-otel-metrics-svc-name/$OtelMetricsSvcName/" copilot/$OtelMetricsSvcName/manifest.yml

sed -i -r "s/otel-collector-url/$OtelMetricsSvcName/" copilot/$OtelMetricsSvcName/otel-collector-metrics-config.yaml
p="${path}${OtelMetricsSvcName}"
sed -i -r "s/some-path/$p/" copilot/$OtelMetricsSvcName/manifest.yml
rm copilot/$OtelMetricsSvcName/manifest.yml-r
rm copilot/$OtelMetricsSvcName/otel-collector-metrics-config.yaml-r


mkdir -p copilot/$QuerySvcName
cp base/query-service/manifest.yml copilot/$QuerySvcName/manifest.yml
cp -r base/query-service/dashboards copilot/$QuerySvcName/dashboards
cp -R base/query-service/data copilot/$QuerySvcName/data
cp base/query-service/prometheus.yml copilot/$QuerySvcName/prometheus.yml
cp base/query-service/Dockerfile copilot/$QuerySvcName/Dockerfile

sed -i -r "s/some-query-service/$QuerySvcName/" copilot/$QuerySvcName/manifest.yml
sed -i -r "s/some-alert-manager-url/$AlertManagerServiceAddress/" copilot/$QuerySvcName/prometheus.yml
sed -i -r "s/some-alert-manager-url/$AlertManagerServiceAddress/" copilot/$QuerySvcName/Dockerfile
p="${path}${QuerySvcName}"
sed -i -r "s/some-path/$p/" copilot/$QuerySvcName/manifest.yml

rm copilot/$QuerySvcName/prometheus.yml-r
rm copilot/$QuerySvcName/manifest.yml-r


mkdir -p copilot/$AlertManagerSvcName
cp base/alert-manager/manifest.yml copilot/$AlertManagerSvcName/manifest.yml
cp -r base/alert-manager/data copilot/$AlertManagerSvcName/data
cp base/alert-manager/Dockerfile copilot/$AlertManagerSvcName/Dockerfile

p="${path}${AlertManagerSvcName}"
sed -i -r "s/some-alert-service/$AlertManagerSvcName/" copilot/$AlertManagerSvcName/manifest.yml
sed -i -r "s/some-query-service-url/$QueryServiceAddressInternal/" copilot/$AlertManagerSvcName/manifest.yml
sed -i -r "s/some-query-service-url/$QueryServiceAddressInternal/" copilot/$AlertManagerSvcName/Dockerfile
sed -i -r "s/some-path/$p/" copilot/$AlertManagerSvcName/manifest.yml

rm copilot/$AlertManagerSvcName/manifest.yml-r


mkdir -p copilot/$FrontendSvcName
cp base/frontend/manifest.yml copilot/$FrontendSvcName/manifest.yml
cp -r base/frontend/common copilot/$FrontendSvcName/common
cp base/frontend/Dockerfile copilot/$FrontendSvcName/Dockerfile

p="${path}${FrontendSvcName}"
sed -i -r "s/some-frontend/$FrontendSvcName/" copilot/$FrontendSvcName/manifest.yml
sed -i -r "s/some-alert-manager-url/$AlertManagerServiceAddress/" copilot/$FrontendSvcName/common/nginx-config.conf
sed -i -r "s/some-query-service/$QueryServiceAddress/" copilot/$FrontendSvcName/common/nginx-config.conf
sed -i -r "s/some-path/$p/" copilot/$FrontendSvcName/manifest.yml

rm copilot/$FrontendSvcName/manifest.yml-r
rm copilot/$FrontendSvcName/common/nginx-config.conf-r

p="${path}test-svc"
mkdir -p copilot/test-svc
cp -r base/gin-app/ copilot/test-svc/
sed -i -r "s/some-otel-endpoint/$OtelServiceAddress/" copilot/test-svc/Dockerfile
sed -i -r "s/some-path/$p/" copilot/test-svc/manifest.yml

copilot app init $AppName

# copilot init -a "$AppName" -t "Backend Service" -n "$OtelSvcName"
copilot env init --name $2 --profile default --default-config
copilot env deploy --name $2


copilot svc init -a "$AppName" -t "Backend Service" -n "$OtelSvcName"
copilot svc deploy --name "$OtelSvcName" -e "$2" 
copilot svc init -a "$AppName" -t "Backend Service" -n "$OtelMetricsSvcName"
copilot svc deploy --name "$OtelMetricsSvcName" -e "$2" 
copilot svc init -a "$AppName" -t "Backend Service" -n "$QuerySvcName"
copilot svc  deploy --name "$QuerySvcName" -e "$2" 
copilot svc init -a "$AppName" -t "Backend Service" -n "$AlertManagerSvcName"
copilot svc deploy --name "$AlertManagerSvcName" -e "$2" 
copilot svc init -a "$AppName" -t "Load Balanced Web Service" -n "$FrontendSvcName"


copilot svc deploy --name "$FrontendSvcName" -e "$2" 

exit 
