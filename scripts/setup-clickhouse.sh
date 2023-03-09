#!/bin/bash
 clickhouseStackName=$(yq '.signoz-app.clickhouse-stack-name' signoz-ecs-config.yml)
[ -z "$clickhouseStackName" ] && echo "No clickhouse service name argument supplied" && exit 1

clickhouseDiskSize=$(yq '.signoz-app.clickhouse-disk-size' signoz-ecs-config.yml)
[ -z "$clickhouseDiskSize" ] && echo "No clickhouse disk size parameter provided will use defautl value 100 gb"

zookeeperDiskSize=$(yq '.signoz-app.zookeeper-disk-size' signoz-ecs-config.yml)
[ -z "$zookeeperDiskSize" ] && echo "No zookeepr disk size parameter provided will use defautl value 100 gb"

zookeeperInstanceType=$(yq '.signoz-app.zookeeper-instance-type' signoz-ecs-config.yml)
[ -z "$zookeeperInstanceType" ] && echo "No zookeeper instance parameter provided will use defautl value t2.small"

clickhouseInstanceType=$(yq '.signoz-app.clickhouse-instance-type' signoz-ecs-config.yml)
[ -z "$clickhouseInstanceType" ] && echo "No clickhouse instance parameter provided will use defautl value t2.small"    




aws cloudformation validate-template --template-body file://clickhouse.yaml --no-cli-pager
aws cloudformation create-stack --template-body file://clickhouse.yaml --stack-name $clickhouseStackName --no-cli-pager --parameters ParameterKey=ZookeeperInstanceType,ParameterValue=$zookeeperInstanceType ParameterKey=RootVolumeSize,ParameterValue=$zookeeperDiskSize ParameterKey=ClickhouseInstanceType,ParameterValue=$clickhouseInstanceType  &> /dev/null
set -e
aws cloudformation wait stack-create-complete --stack-name $clickhouseStackName
export vpcId=$(aws cloudformation describe-stacks --stack-name clickhouse --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="VpcId").OutputValue')
echo $vpcId
yq -i e '.signoz-app.vpc-id |= env(vpcId)' signoz-ecs-config.yml

export publicSubNetAId=$(aws cloudformation describe-stacks --stack-name clickhouse --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PublicSubNetAId").OutputValue')
echo $publicSubNetAId
yq -i e '.signoz-app.public-subnet-a-id |= env(publicSubNetAId)' signoz-ecs-config.yml

export publicSubNetBId=$(aws cloudformation describe-stacks --stack-name clickhouse --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PublicSubNetBId").OutputValue')
echo $publicSubNetBId
yq -i e '.signoz-app.public-subnet-b-id |= env(publicSubNetBId)' signoz-ecs-config.yml

export privateSubNetAId=$(aws cloudformation describe-stacks --stack-name clickhouse --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PrivateSubNetAId").OutputValue')
echo $privateSubNetAId
yq -i e '.signoz-app.private-subnet-a-id |= env(privateSubNetAId)' signoz-ecs-config.yml

export privateSubNetBId=$(aws cloudformation describe-stacks --stack-name clickhouse --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PrivateSubNetBId").OutputValue')
echo $privateSubNetBId
yq -i e '.signoz-app.private-subnet-b-id |= env(privateSubNetBId)' signoz-ecs-config.yml

export clickhouseHost=$(aws cloudformation describe-stacks --stack-name clickhouse --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="ClickhouseDnsHost").OutputValue')
echo $clickhouseHost
yq -i e '.signoz-app.clickhouse-host-name |= env(clickhouseHost)' signoz-ecs-config.yml


echo "succesfully setup a clickhouse cluster"