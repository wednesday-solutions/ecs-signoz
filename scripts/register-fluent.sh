#!/bin/bash

export fileName=signoz-ecs-config.yml


otelEndpoint=$(yq '.signoz-app.otel-service-endpoint' output.yml)
[ -z "$otelEndpoint" ] && echo "No otel endpoint present " && exit 1


mkdir -p copilot/fluentbit
cp -r base/fluentbit/ copilot/fluentbit/



sed -i -r "s/some-otel-endpoint/$otelEndpoint/" copilot/test-svc/manifest.yml
rm copilot/test-svc/manifest.yml-r





accountId=$(aws sts get-caller-identity --output json | jq -r '.Account')
region=$(aws configure get region)
repoName=$(yq '.signoz-app.fluentbitConf.repoName' $fileName)
imageName=$(yq '.signoz-app.fluentbitConf.localImageName' $fileName)

docker build -t $imageName ./copilot/fluentbit 

if [[ $? -ne 0 ]] ; then
    exit 1
fi




export imageUrl=$accountId.dkr.ecr.$region.amazonaws.com/$repoName



echo $repoName

aws ecr get-login-password --region $region | docker login --username AWS --password-stdin $accountId.dkr.ecr.$region.amazonaws.com

aws ecr create-repository --repository-name $repoName --image-scanning-configuration scanOnPush=true --region $region --output json > /dev/null
docker tag $imageName:latest $imageUrl
docker push $imageUrl

yq e -i '.signoz-app.fluentbitConf.imageUrl |= env(imageUrl)' output.yml 

