#!/bin/bash
 clickhouseStackName=$(yq '.signoz-app.clickhouseConf.stackName' signoz-ecs-config.yml)-signoz
[ -z "$clickhouseStackName" ] && echo "No clickhouse service name argument supplied" && exit 1

clickhouseDiskSize=$(yq '.signoz-app.clickhouseConf.clickhouseDiskSize' signoz-ecs-config.yml)
[ -z "$clickhouseDiskSize" ] && echo "No clickhouse disk size parameter provided will use defautl value 100 gb"

zookeeperDiskSize=$(yq '.signoz-app.clickhouseConf.zookeeperDiskSize' signoz-ecs-config.yml)
[ -z "$zookeeperDiskSize" ] && echo "No zookeepr disk size parameter provided will use defautl value 100 gb"

zookeeperInstanceType=$(yq '.signoz-app.clickhouseConf.zookeeperInstanceType' signoz-ecs-config.yml)
[ -z "$zookeeperInstanceType" ] && echo "No zookeeper instance parameter provided will use defautl value t2.small"

clickhouseInstanceType=$(yq '.signoz-app.clickhouseConf.instanceType' signoz-ecs-config.yml)
[ -z "$clickhouseInstanceType" ] && echo "No clickhouse instance parameter provided will use defautl value t2.small"    

vpcId=$(yq '.signoz-app.existingVpc.vpcId' signoz-ecs-config.yml)
[ -z "$vpcId" ] && echo "please provide a vpc id if you are using an existing vpc" && exit 1    

publicSubnetAId=$(yq '.signoz-app.existingVpc.publicSubnetAId' signoz-ecs-config.yml)
[ -z "$publicSubnetAId" ] && echo "please provide id of a public subnet" && exit 1   

publicSubnetBId=$(yq '.signoz-app.existingVpc.publicSubnetBId' signoz-ecs-config.yml)
[ -z "$publicSubnetBId" ] && echo "please provide id of a public subnet" && exit 1   

privateSubnetAId=$(yq '.signoz-app.existingVpc.privateSubnetAId' signoz-ecs-config.yml)
[ -z "$privateSubnetAId" ] && echo "please provide id of a private subnet" && exit 1   

privateSubnetBId=$(yq '.signoz-app.existingVpc.privateSubnetBId' signoz-ecs-config.yml)
[ -z "$privateSubnetBId" ] && echo "please provide id of a private subnet" && exit 1   



aws cloudformation validate-template --template-body file://clickhouse-custom-vpc.yaml --no-cli-pager 
aws cloudformation create-stack --template-body file://clickhouse-custom-vpc.yaml --stack-name $clickhouseStackName --capabilities CAPABILITY_IAM --no-cli-pager \
--parameters ParameterKey=ZookeeperInstanceType,ParameterValue=$zookeeperInstanceType \
    ParameterKey=RootVolumeSize,ParameterValue=$zookeeperDiskSize \
    ParameterKey=ClickhouseInstanceType,ParameterValue=$clickhouseInstanceType \
    ParameterKey=RootVolumeSize,ParameterValue=$zookeeperDiskSize \
    ParameterKey=VpcId,ParameterValue=$vpcId\
    ParameterKey=PublicSubnetAId,ParameterValue=$publicSubnetAId\
    ParameterKey=PublicSubnetBId,ParameterValue=$publicSubnetBId\
    ParameterKey=PrivateSubnetAId,ParameterValue=$privateSubnetAId ParameterKey=PrivateSubnetBId,ParameterValue=$privateSubnetBId

set -e
aws cloudformation wait stack-create-complete --stack-name $clickhouseStackName
export vpcId=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="VpcId").OutputValue')
echo $vpcId
yq -i e '.signoz-app.existingVpc.vpcId |= env(vpcId)' output.yml

export publicSubNetAId=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PublicSubNetAId").OutputValue')
echo $publicSubNetAId
yq -i e '.signoz-app.existingVpc.publicSubnetAId |= env(publicSubNetAId)' output.yml

export publicSubNetBId=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PublicSubNetBId").OutputValue')
echo $publicSubNetBId
yq -i e '.signoz-app.existingVpc.publicSubnetBId |= env(publicSubNetBId)' output.yml

export privateSubNetAId=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PrivateSubNetAId").OutputValue')
echo $privateSubNetAId
yq -i e '.signoz-app.existingVpc.privateSubnetAId |= env(privateSubNetAId)' output.yml

export privateSubNetBId=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PrivateSubNetBId").OutputValue')
echo $privateSubNetBId
yq -i e '.signoz-app.existingVpc.privateSubnetBId |= env(privateSubNetBId)' output.yml

export clickhouseHost=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="ClickhouseDnsHost").OutputValue')
echo $clickhouseHost
yq -i e '.signoz-app.clickhouseConf.hostName |= env(clickhouseHost)' output.yml


echo "succesfully setup a clickhouse cluster"