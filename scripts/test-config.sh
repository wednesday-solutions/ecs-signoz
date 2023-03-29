#!/bin/bash

yq -i e '.signoz-app.application-name |= "test-signoz-1"' signoz-ecs-config.yml
yq -i e '.signoz-app.clickhouseConf.stackName |= "test-signoz-1"' signoz-ecs-config.yml