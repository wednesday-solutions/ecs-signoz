appName=$(yq '.signoz-app.application-name' signoz-ecs-config.yml)
[ -z "$appName" ] && echo "No app name argument supplied" && exit 1
AppName="$appName-app"

copilot app delete $AppName --yes 