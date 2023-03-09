echo "This will delete your copilot  services"


otel=$(yq '.signoz-app.otel-service-name' signoz-ecs-config.yml)
query=$(yq '.signoz-app.query-servcice-name' signoz-ecs-config.yml)
alert=$(yq '.signoz-app.alert-service-name' signoz-ecs-config.yml)
frontend=$(yq '.signoz-app.frontend-service-name' signoz-ecs-config.yml)

OtelSvcName="$otel-svc"
OtelMetricsSvcName="$otel-metrics-svc"
QuerySvcName="$query-svc"
AlertManagerSvcName="$alert-svc"
FrontendSvcName="$frontend-svc"

env=$(yq '.signoz-app.environment-name' signoz-ecs-config.yml)-signoz

[ -z "$appName" ] && echo "No app name argument supplied" && exit 1
AppName="$appName-app"

copilot svc delete -n $OtelSvcName -e $env --yes 
copilot svc delete -n $OtelMetricsSvcName -e $env --yes 
copilot svc delete -n $QuerySvcName -e $env --yes 
copilot svc delete -n $AlertManagerSvcName -e $env --yes 
copilot svc delete -n $FrontendSvcName -e $env --yes 