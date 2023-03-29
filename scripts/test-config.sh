#!/bin/bash

yq -i '.signoz-app.application-name = "test-signoz-1"' signoz-ecs-config.yml
yq -i '.signoz-app.clickhouseConf.stackName = "test-signoz-1"' signoz-ecs-config.yml