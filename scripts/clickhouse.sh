#!/bin/bash


str1=$(yq '.signoz-app.existing-vpc' signoz-ecs-config.yml)

if [ "$str1" = "true" ]; then
    ./scripts/setup-clickhouse-with-existing-vpc.sh
else
     ./scripts/setup-clickhouse.sh
fi