appName=$(yq e '.signoz-app.application-name' signoz-ecs-config.yml)
echo " you have set the app name as $appName"
