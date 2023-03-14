#!/bin/bash

exVpcField=$(yq '.signoz-app | has("existingVpc")' signoz-ecs-config.yml)
vpcId=$(yq '.signoz-app.existingVpc.vpcId' signoz-ecs-config.yml)

if [ "$exVpcField" = "true" ] && [ "$vpcId" != "" ] ; then
    ./scripts/setup-clickhouse-with-existing-vpc.sh
    
else
     ./scripts/setup-clickhouse.sh
   
fi