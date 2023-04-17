echo "This will delete your copilot  services"

export fileName=signoz-ecs-config.yml
[! -z "$environmentName" ] && export fileName=signoz-ecs-config-$environmentName.yml

otel=$(yq '.signoz-app.serviceNames.otel' $fileName)
query=$(yq '.signoz-app.serviceNames.query' $fileName)
alert=$(yq '.signoz-app.serviceNames.alert' $fileName)
frontend=$(yq '.signoz-app.serviceNames.frontend' $fileName)

OtelSvcName="$otel-svc"
OtelMetricsSvcName="$otel-metrics-svc"
QuerySvcName="$query-svc"
AlertManagerSvcName="$alert-svc"
FrontendSvcName="$frontend-svc"

env=$(yq '.signoz-app.environment-name' $fileName)-signoz


copilot svc delete -n $OtelSvcName -e $env --yes 
copilot svc delete -n $OtelMetricsSvcName -e $env --yes 
copilot svc delete -n $QuerySvcName -e $env --yes 
copilot svc delete -n $AlertManagerSvcName -e $env --yes 
copilot svc delete -n $FrontendSvcName -e $env --yes 