#!/bin/bash


export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2

appName=$(yq '.signoz-app.application-name' signoz-ecs-config.yml)
echo "This will delete your copilot app,environment and all the services"
copilot app delete $AppName --yes
clickhouseCluster=$(yq '.signoz-app.clickhouseConf.stackName' signoz-ecs-config.yml)-signoz
echo "This will delete your cloudformation stack"
aws cloudformation delete-stack --stack-name $clickhouseCluster 
aws cloudformation wait stack-delete-complete --stack-name $clickhouseCluster