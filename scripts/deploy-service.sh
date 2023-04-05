#!/bin/bash

appName=$(yq '.signoz-app.application-name' signoz-ecs-config.yml)
envName=$(yq '.signoz-app.environment-name' signoz-ecs-config.yml)-signoz

otel=$(yq '.signoz-app.serviceNames.otel' signoz-ecs-config.yml)
query=$(yq '.signoz-app.serviceNames.query' signoz-ecs-config.yml)
alert=$(yq '.signoz-app.serviceNames.alert' signoz-ecs-config.yml)
frontend=$(yq '.signoz-app.serviceNames.frontend' signoz-ecs-config.yml)

clickhouseHost=$(yq '.signoz-app.clickhouseConf.hostName' signoz-ecs-config.yml)


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



AppName="$appName-app"
OtelSvcName="$otel-svc"
OtelMetricsSvcName="$otel-metrics-svc"
QuerySvcName="$query-svc"
AlertManagerSvcName="$alert-svc"
FrontendSvcName="$frontend-svc"


export OtelServiceAddress="${OtelSvcName}.${envName}.${AppName}.local:4317"
export Osa="${OtelSvcName}.${envName}.${AppName}.local"
yq e -i '.signoz-app.otel-service-endpoint |= env(Osa)' output.yml 
# OtelServiceAddressInternal="${OtelSvcName}.${envName}.${AppName}.local:8889"
# QueryServiceAddress="${QuerySvcName}.${envName}.${AppName}.local:8080"
# QueryServiceAddressInternal="${QuerySvcName}.${envName}.${AppName}.local:8085"
# AlertManagerServiceAddress="${AlertManagerSvcName}.${envName}.${AppName}.local:9093"

# path=".\/copilot\/"


copilot svc init -a "$AppName" -t "Backend Service" -n "$OtelSvcName"
copilot svc deploy --name "$OtelSvcName" -e "$envName" 
copilot svc init -a "$AppName" -t "Backend Service" -n "$OtelMetricsSvcName"
copilot svc deploy --name "$OtelMetricsSvcName" -e "$envName" 
copilot svc init -a "$AppName" -t "Backend Service" -n "$QuerySvcName"
copilot svc  deploy --name "$QuerySvcName" -e "$envName" 
copilot svc init -a "$AppName" -t "Backend Service" -n "$AlertManagerSvcName"
copilot svc deploy --name "$AlertManagerSvcName" -e "$envName" 
./scripts/loadBalancer.sh



copilot svc init -a "$AppName" -t "Backend Service" -n "$FrontendSvcName"
copilot svc deploy --name "$FrontendSvcName" -e "$envName" 
envName=$(yq '.signoz-app.environment-name' signoz-ecs-config.yml)-signoz
albName=$AppName-$envName-FrontendLoadBalancerDNS

export dnsFrontend=$(aws cloudformation list-exports --no-cli-pager --query "Exports[?Name == '$albName'].Value | [0]" )
echo "visit the fronted on $dnsFrontend"   
yq e -i '.signoz-app.frontendURL |= env(dnsFrontend)' output.yml