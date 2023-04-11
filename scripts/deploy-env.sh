#!/bin/bash

export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2
appName=$(yq '.signoz-app.application-name' signoz-ecs-config.yml)
[ -z "$appName" ] && echo "No app name argument supplied" && exit 1
AppName="$appName-app"
copilot app init $AppName

#creating a clickhouse cluster

envName=$(yq '.signoz-app.environment-name' signoz-ecs-config.yml)-signoz
[ -z "$envName" ] && echo "No env name argument is provided" && exit 1

vpcId=$(yq '.signoz-app.existingVpc.vpcId' output.yml)
[ -z "$vpcId" ] && echo "please provide a vpc id if you are using an existing vpc" && exit 1    

publicSubnetAId=$(yq '.signoz-app.existingVpc.publicSubnetAId' output.yml)
[ -z "$publicSubnetAId" ] && echo "please provide id of a public subnet" && exit 1   

publicSubnetBId=$(yq '.signoz-app.existingVpc.publicSubnetBId' output.yml)
[ -z "$publicSubnetBId" ] && echo "please provide id of a public subnet" && exit 1   

privateSubnetAId=$(yq '.signoz-app.existingVpc.privateSubnetAId' output.yml)
[ -z "$privateSubnetAId" ] && echo "please provide id of a private subnet" && exit 1   

privateSubnetBId=$(yq '.signoz-app.existingVpc.privateSubnetBId' output.yml)
[ -z "$privateSubnetBId" ] && echo "please provide id of a private subnet" && exit 1   

echo $privateSubnetAId
# creating env from cloudformation provided vpc and subnet
copilot env init --name $envName --profile default --import-vpc-id $vpcId --import-private-subnets $privateSubnetAId,$privateSubnetBId --import-public-subnets $publicSubnetAId,$publicSubnetBId
copilot env deploy --name $envName