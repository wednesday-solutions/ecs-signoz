#!/bin/bash


appName=$(yq '.signoz-app.application-name' signoz-ecs-config.yml)
envName=$(yq '.signoz-app.environment-name' signoz-ecs-config.yml)-signoz

otel=$(yq '.signoz-app.serviceNames.otel' signoz-ecs-config.yml)
query=$(yq '.signoz-app.serviceNames.query' signoz-ecs-config.yml)
alert=$(yq '.signoz-app.serviceNames.alert' signoz-ecs-config.yml)
frontend=$(yq '.signoz-app.serviceNames.frontend' signoz-ecs-config.yml)

export clickhouseHost=$(yq '.signoz-app.clickhouseConf.hostName' signoz-ecs-config.yml)

filename=output.yml
test -f $filename || touch $filename

[ -z "$appName" ] && echo "No app name argument supplied" && exit 1

[ -z "$envName" ] && echo "No env name argument is provided" && exit 1

[ -z "$otel" ] && echo "No otel collector service name argument supplied" && exit 1

[ -z "$query" ] && echo "No query server service name argument supplied" && exit 1

[ -z "$alert" ] && echo "No alert manager service name argument supplied" && exit 1

[ -z "$frontend" ] && echo "No frontend service name argument supplied" && exit 1



echo "application name $appName-app"

echo "environment name $envName"

echo "otel collector name $otel-svc"

echo "otel collector metrics $otel-metrics-svc"

echo "query service name $query-svc"

echo "alert manager service name $alert-svc"

echo "frontend $frontend-svc"

echo "starting to deploy clickhouse cluster"

if [ -z "$clickhouseHost" ]
then
./scripts/clickhouse.sh
else
yq e -i '.signoz-app.clickhouseConf.hostName |= env(clickhouseHost)' output.yml
fi



clickhouseHost=$(yq '.signoz-app.clickhouseConf.hostName' output.yml)

[ -z "$clickhouseHost" ] && echo "error loading clickhouse host" && exit 1




AppName="$appName-app"
OtelSvcName="$otel-svc"
OtelMetricsSvcName="$otel-metrics-svc"
QuerySvcName="$query-svc"
AlertManagerSvcName="$alert-svc"
FrontendSvcName="$frontend-svc"


OtelServiceAddress="${OtelSvcName}.${envName}.${AppName}.local:4317"
OtelServiceHost="${OtelSvcName}.${envName}.${AppName}.local"
OtelServiceAddressInternal="${OtelSvcName}.${envName}.${AppName}.local:8889"
QueryServiceAddress="${QuerySvcName}.${envName}.${AppName}.local:8080"
QueryServiceAddressInternal="${QuerySvcName}.${envName}.${AppName}.local:8085"
AlertManagerServiceAddress="${AlertManagerSvcName}.${envName}.${AppName}.local:9093"

path=".\/copilot\/"


ls -a


# setting up config files
echo "creating copilot folder"
mkdir -p copilot/$OtelSvcName
ls -a 
cp base/otel-collector/manifest.yml copilot/$OtelSvcName/manifest.yml
cp base/otel-collector/Dockerfile copilot/$OtelSvcName/Dockerfile
cp base/otel-collector/otel-collector-config.yaml copilot/$OtelSvcName/otel-collector-config.yaml 

sed -i -r "s/some-otel-svc-name/$OtelSvcName/" copilot/$OtelSvcName/manifest.yml
sed -i -r "s/clickhouse-host/$clickhouseHost/" copilot/$OtelSvcName/otel-collector-config.yaml
p="${path}${OtelSvcName}"
sed -i -r "s/some-path/$p/" copilot/$OtelSvcName/manifest.yml
rm copilot/$OtelSvcName/manifest.yml-r
rm copilot/$OtelSvcName/otel-collector-config.yaml-r



mkdir -p copilot/$OtelMetricsSvcName
cp base/otel-metrics-collector/manifest.yml copilot/$OtelMetricsSvcName/manifest.yml
cp base/otel-metrics-collector/otel-collector-metrics-config.yaml copilot/$OtelMetricsSvcName/otel-collector-metrics-config.yaml
cp base/otel-metrics-collector/Dockerfile copilot/$OtelMetricsSvcName/Dockerfile



sed -i -r "s/some-otel-metrics-svc-name/$OtelMetricsSvcName/" copilot/$OtelMetricsSvcName/manifest.yml

sed -i -r "s/otel-collector-url/$OtelMetricsSvcName/" copilot/$OtelMetricsSvcName/otel-collector-metrics-config.yaml
sed -i -r "s/clickhouse-host/$clickhouseHost/" copilot/$OtelMetricsSvcName/otel-collector-metrics-config.yaml
p="${path}${OtelMetricsSvcName}"
sed -i -r "s/some-path/$p/" copilot/$OtelMetricsSvcName/manifest.yml
rm copilot/$OtelMetricsSvcName/manifest.yml-r
rm copilot/$OtelMetricsSvcName/otel-collector-metrics-config.yaml-r


mkdir -p copilot/$QuerySvcName
cp base/query-service/manifest.yml copilot/$QuerySvcName/manifest.yml
cp base/query-service/prometheus.yml copilot/$QuerySvcName/prometheus.yml
cp base/query-service/Dockerfile copilot/$QuerySvcName/Dockerfile

sed -i -r "s/some-query-service/$QuerySvcName/" copilot/$QuerySvcName/manifest.yml
sed -i -r "s/some-alert-manager-url/$AlertManagerServiceAddress/" copilot/$QuerySvcName/prometheus.yml
sed -i -r "s/some-alert-manager-url/$AlertManagerServiceAddress/" copilot/$QuerySvcName/Dockerfile
sed -i -r "s/clickhouse-host/$clickhouseHost/" copilot/$QuerySvcName/Dockerfile
sed -i -r "s/clickhouse-host/$clickhouseHost/" copilot/$QuerySvcName/prometheus.yml

p="${path}${QuerySvcName}"
sed -i -r "s/some-path/$p/" copilot/$QuerySvcName/manifest.yml

rm copilot/$QuerySvcName/prometheus.yml-r
rm copilot/$QuerySvcName/manifest.yml-r
rm copilot/$QuerySvcName/Dockerfile-r


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
rm copilot/$AlertManagerSvcName/Dockerfile-r


mkdir -p copilot/$FrontendSvcName
cp base/frontend/manifest.yml copilot/$FrontendSvcName/manifest.yml
cp -r base/frontend/common/ copilot/$FrontendSvcName/common
cp -r base/frontend/overrides/ copilot/$FrontendSvcName/overrides
cp base/frontend/Dockerfile copilot/$FrontendSvcName/Dockerfile
cp base/frontend/nginxReload.sh copilot/$FrontendSvcName/nginxReload.sh
cp base/frontend/start.sh copilot/$FrontendSvcName/start.sh

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
sed -i -r "s/some-otel-endpoint/$OtelServiceHost/" copilot/test-svc/manifest.yml

sed -i -r "s/some-path/$p/" copilot/test-svc/manifest.yml


