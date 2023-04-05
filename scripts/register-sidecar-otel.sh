#!/bin/bash




otelEndpoint=$(yq '.signoz-app.otel-service-endpoint' output.yml)
[ -z "$otelEndpoint" ] && echo "No otel endpoint present " && exit 1


mkdir -p copilot/sidecar-otel
cp -r base/sidecar-otel/ copilot/sidecar-otel/



sed -i -r "s/some-otel-endpoint/$otelEndpoint/" copilot/sidecar-otel/config.yaml






accountId=$(aws sts get-caller-identity --output json | jq -r '.Account')
region=$(aws configure get region)
repoName=$(yq '.signoz-app.otelSidecarConf.repoName' signoz-ecs-config.yml)
imageName=$(yq '.signoz-app.otelSidecarConf.localImageName' signoz-ecs-config.yml)

docker build -t $imageName ./copilot/sidecar-otel

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

