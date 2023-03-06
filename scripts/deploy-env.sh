#!/bin/bash

appName=$(yq '.signoz-app.application-name' signoz-ecs-config.yml)
[ -z "$appName" ] && echo "No app name argument supplied" && exit 1
AppName="$appName-app"
copilot app init $AppName

#creating a clickhouse cluster

envName=$(yq '.signoz-app.environment-name' signoz-ecs-config.yml)
[ -z "$envName" ] && echo "No env name argument is provided" && exit 1

vpcId=$(yq '.signoz-app.vpc-id' signoz-ecs-config.yml)
[ -z "$vpcId" ] && echo "please provide a vpc id if you are using an existing vpc" && exit 1    

publicSubnetAId=$(yq '.signoz-app.public-subnet-a-id' signoz-ecs-config.yml)
[ -z "$publicSubnetAId" ] && echo "please provide id of a public subnet" && exit 1   

publicSubnetBId=$(yq '.signoz-app.public-subnet-b-id' signoz-ecs-config.yml)
[ -z "$publicSubnetBId" ] && echo "please provide id of a public subnet" && exit 1   

privateSubnetAId=$(yq '.signoz-app.private-subnet-a-id' signoz-ecs-config.yml)
[ -z "$privateSubnetAId" ] && echo "please provide id of a private subnet" && exit 1   

privateSubnetBId=$(yq '.signoz-app.private-subnet-b-id' signoz-ecs-config.yml)
[ -z "$privateSubnetBId" ] && echo "please provide id of a private subnet" && exit 1   

echo $privateSubnetAId
# creating env from cloudformation provided vpc and subnet
copilot env init --name $envName --profile default --import-vpc-id $vpcId --import-private-subnets $privateSubnetAId,$privateSubnetBId --import-public-subnets $publicSubnetAId,$publicSubnetBId
copilot env deploy --name $envName