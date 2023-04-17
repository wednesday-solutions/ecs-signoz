#!/bin/bash


#creating a clickhouse cluster
export fileName=signoz-ecs-config.yml


envName=$(yq '.signoz-app.environment-name' $fileName)-signoz
[ -z "$envName" ] && echo "No env name argument is provided" && exit 1




cp -r ./base/frontend/addons ./copilot/environments/

copilot env deploy --name $envName