#!/bin/bash
 clickhouseStackName=$(yq '.signoz-app.clickhouse-stack-name' signoz-ecs-config.yml)-signoz
[ -z "$clickhouseStackName" ] && echo "No clickhouse service name argument supplied" && exit 1

clickhouseDiskSize=$(yq '.signoz-app.clickhouse-disk-size' signoz-ecs-config.yml)
[ -z "$clickhouseDiskSize" ] && echo "No clickhouse disk size parameter provided will use defautl value 100 gb"

zookeeperDiskSize=$(yq '.signoz-app.zookeeper-disk-size' signoz-ecs-config.yml)
[ -z "$zookeeperDiskSize" ] && echo "No zookeepr disk size parameter provided will use defautl value 100 gb"

zookeeperInstanceType=$(yq '.signoz-app.zookeeper-instance-type' signoz-ecs-config.yml)
[ -z "$zookeeperInstanceType" ] && echo "No zookeeper instance parameter provided will use defautl value t2.small"

clickhouseInstanceType=$(yq '.signoz-app.clickhouse-instance-type' signoz-ecs-config.yml)
[ -z "$clickhouseInstanceType" ] && echo "No clickhouse instance parameter provided will use defautl value t2.small"    

vpcId=$(yq '.signoz-app.vpc-id' signoz-ecs-config.yml)
[ -z "$vpcId" ] && echo "please provide a vpc id if you are using an existing vpc" && exit 1    

publicSubnetAId=$(yq '.signoz-app.public-subnet-a-id' signoz-ecs-config.yml)
[ -z "$publicSubnetAId" ] && echo "please provide id of a public subnet" && exit 1   

publicSubnetBId=$(yq '.signoz-app.public-subnet-b-id' signoz-ecs-config.yml)
[ -z "$publicSubnetBId" ] && echo "please provide id of a public subnet" && exit 1   

privateSubnetAId=$(yq '.signoz-app.private-subnet-a-id' signoz-ecs-config.yml)
[ -z "$privateSubnetAId" ] && echo "please provide id of a private subnet" && exit 1   

privateSubnetBId=$(yq '.signoz-app.private-subnet-b-id' signoz-ecs-config.yml)
[ -z "$privateSubnetBId" ] && echo "please provide id of a private subnet" && exit 1   



aws cloudformation validate-template --template-body file://clickhouse-custom-vpc.yaml --no-cli-pager \
aws cloudformation create-stack --template-body file://clickhouse-custom-vpc.yaml --stack-name $clickhouseStackName --no-cli-pager \
--parameters ParameterKey=ZookeeperInstanceType,ParameterValue=$zookeeperInstanceType \
    ParameterKey=RootVolumeSize,ParameterValue=$zookeeperDiskSize \
    ParameterKey=ClickhouseInstanceType,ParameterValue=$clickhouseInstanceType \
    ParameterKey=RootVolumeSize,ParameterValue=$zookeeperDiskSize \
    ParameterKey=VpcId,ParameterValue=$vpcId\
    ParameterKey=PublicSubnetAId,ParameterValue=$publicSubnetAId\
    ParameterKey=PublicSubnetBId,ParameterValue=$publicSubnetBId\
    ParameterKey=PrivateSubnetAId,ParameterValue=$privateSubnetAId \ 
    ParameterKey=PrivateSubnetBId,ParameterValue=$privateSubnetBId \ 
    &> /dev/null
set -e
aws cloudformation wait stack-create-complete --stack-name $clickhouseStackName
export vpcId=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="VpcId").OutputValue')
echo $vpcId
yq -i e '.signoz-app.vpc-id |= env(vpcId)' signoz-ecs-config.yml

export publicSubNetAId=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PublicSubNetAId").OutputValue')
echo $publicSubNetAId
yq -i e '.signoz-app.public-subnet-a-id |= env(publicSubNetAId)' signoz-ecs-config.yml

export publicSubNetBId=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PublicSubNetBId").OutputValue')
echo $publicSubNetBId
yq -i e '.signoz-app.public-subnet-b-id |= env(publicSubNetBId)' signoz-ecs-config.yml

export privateSubNetAId=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PrivateSubNetAId").OutputValue')
echo $privateSubNetAId
yq -i e '.signoz-app.private-subnet-a-id |= env(privateSubNetAId)' signoz-ecs-config.yml

export privateSubNetBId=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PrivateSubNetBId").OutputValue')
echo $privateSubNetBId
yq -i e '.signoz-app.private-subnet-b-id |= env(privateSubNetBId)' signoz-ecs-config.yml

export clickhouseHost=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="ClickhouseDnsHost").OutputValue')
echo $clickhouseHost
yq -i e '.signoz-app.clickhouse-host-name |= env(clickhouseHost)' signoz-ecs-config.yml


echo "succesfully setup a clickhouse cluster"