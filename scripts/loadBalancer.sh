#!/bin/bash


#creating a clickhouse cluster

envName=$(yq '.signoz-app.environment-name' signoz-ecs-config.yml)-signoz
[ -z "$envName" ] && echo "No env name argument is provided" && exit 1




cp -r ./base/frontend/addons ./copilot/environments/

copilot env deploy --name $envName