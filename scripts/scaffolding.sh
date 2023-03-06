#!/bin/bash

[ -z "$1" ] && echo "No service name argument supplied" && exit 1


fluentbitImageUrl=$(yq '.signoz-app.fluentbit-image-url' signoz-ecs-config.yml)

mkdir -p copilot/$1
cp base/otel-collector/manifest.yml copilot/$1/manifest.yml


sed -i -r "s/svc-name/$1/" copilot/$1/manifest.yml
sed -i -r "s/some-fluentbit-image/$1/" copilot/$fluentbitImageUrl/manifest.yml

p="${path}${OtelSvcName}"
sed -i -r "s/some-path/$p/" copilot/$fluentbitImageUrl/manifest.yml
rm copilot/$OtelSvcName/manifest.yml-r
