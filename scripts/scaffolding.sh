#!/bin/bash

[ -z "$1" ] && echo "No service name argument supplied" && exit 1


export f=$(yq '.signoz-app.fluentbitConf.imageUrl' output.yml)
export otel=$(yq '.signoz-app.otel-service-endpoint' output.yml)
echo $f
mkdir -p copilot/$1
cp base/sample-app/manifest.yml copilot/$1/manifest.yml


sed -i -r "s/svc-name/$1/" copilot/$1/manifest.yml
sed -i -r "s/some-otel-endpoint/$otel/" copilot/$1/manifest.yml
yq e -i '.logging.image |= env(f)' copilot/$1/manifest.yml

sed -i -r "s/some-path/$p/" copilot/$1/manifest.yml
rm copilot/$1/manifest.yml-r
