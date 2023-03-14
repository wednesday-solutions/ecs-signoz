#!/bin/bash

[ -z "$1" ] && echo "No service name argument supplied" && exit 1


export f=$(yq '.signoz-app.fluentbitConf.imageUrl' signoz-ecs-config.yml)
echo $f
mkdir -p copilot/$1
cp base/sample-app/manifest.yml copilot/$1/manifest.yml


sed -i -r "s/svc-name/$1/" copilot/$1/manifest.yml
yq -i e '.logging.image |= env(f)' copilot/$1/manifest.yml

sed -i -r "s/some-path/$p/" copilot/$1/manifest.yml
rm copilot/$1/manifest.yml-r
