echo "This will delete your copilot  services"


otel=$(yq '.signoz-app.serviceNames.otel' signoz-ecs-config.yml)
query=$(yq '.signoz-app.serviceNames.query' signoz-ecs-config.yml)
alert=$(yq '.signoz-app.serviceNames.alert' signoz-ecs-config.yml)
frontend=$(yq '.signoz-app.serviceNames.frontend' signoz-ecs-config.yml)

OtelSvcName="$otel-svc"
OtelMetricsSvcName="$otel-metrics-svc"
QuerySvcName="$query-svc"
AlertManagerSvcName="$alert-svc"
FrontendSvcName="$frontend-svc"

env=$(yq '.signoz-app.environment-name' signoz-ecs-config.yml)-signoz


copilot svc delete -n $OtelSvcName -e $env --yes 
copilot svc delete -n $OtelMetricsSvcName -e $env --yes 
copilot svc delete -n $QuerySvcName -e $env --yes 
copilot svc delete -n $AlertManagerSvcName -e $env --yes 
copilot svc delete -n $FrontendSvcName -e $env --yes 