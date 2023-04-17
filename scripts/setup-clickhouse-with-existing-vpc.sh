#!/bin/bash

export fileName=signoz-ecs-config.yml
[! -z "$environmentName" ] && export fileName=signoz-ecs-config-$environmentName.yml

 clickhouseStackName=$(yq '.signoz-app.clickhouseConf.stackName' $fileName)-signoz
[ -z "$clickhouseStackName" ] && echo "No clickhouse service name argument supplied" && exit 1

clickhouseDiskSize=$(yq '.signoz-app.clickhouseConf.clickhouseDiskSize' $fileName)
[ -z "$clickhouseDiskSize" ] && echo "No clickhouse disk size parameter provided will use defautl value 100 gb"

zookeeperDiskSize=$(yq '.signoz-app.clickhouseConf.zookeeperDiskSize' $fileName)
[ -z "$zookeeperDiskSize" ] && echo "No zookeepr disk size parameter provided will use defautl value 100 gb"

zookeeperInstanceType=$(yq '.signoz-app.clickhouseConf.zookeeperInstanceType' $fileName)
[ -z "$zookeeperInstanceType" ] && echo "No zookeeper instance parameter provided will use defautl value t2.small"

clickhouseInstanceType=$(yq '.signoz-app.clickhouseConf.instanceType' $fileName)
[ -z "$clickhouseInstanceType" ] && echo "No clickhouse instance parameter provided will use defautl value t2.small"    

vpcId=$(yq '.signoz-app.existingVpc.vpcId' $fileName)
[ -z "$vpcId" ] && echo "please provide a vpc id if you are using an existing vpc" && exit 1    

publicSubnetAId=$(yq '.signoz-app.existingVpc.publicSubnetAId' $fileName)
[ -z "$publicSubnetAId" ] && echo "please provide id of a public subnet" && exit 1   

publicSubnetBId=$(yq '.signoz-app.existingVpc.publicSubnetBId' $fileName)
[ -z "$publicSubnetBId" ] && echo "please provide id of a public subnet" && exit 1   

privateSubnetAId=$(yq '.signoz-app.existingVpc.privateSubnetAId' $fileName)
[ -z "$privateSubnetAId" ] && echo "please provide id of a private subnet" && exit 1   

privateSubnetBId=$(yq '.signoz-app.existingVpc.privateSubnetBId' $fileName)
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
yq e -i '.signoz-app.existingVpc.vpcId |= env(vpcId)' output.yml

export publicSubNetAId=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PublicSubNetAId").OutputValue')
echo $publicSubNetAId
yq e -i '.signoz-app.existingVpc.publicSubnetAId |= env(publicSubNetAId)' output.yml

export publicSubNetBId=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PublicSubNetBId").OutputValue')
echo $publicSubNetBId
yq e -i '.signoz-app.existingVpc.publicSubnetBId |= env(publicSubNetBId)' output.yml

export privateSubNetAId=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PrivateSubNetAId").OutputValue')
echo $privateSubNetAId
yq e -i '.signoz-app.existingVpc.privateSubnetAId |= env(privateSubNetAId)' output.yml

export privateSubNetBId=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PrivateSubNetBId").OutputValue')
echo $privateSubNetBId
yq e -i '.signoz-app.existingVpc.privateSubnetBId |= env(privateSubNetBId)' output.yml

export clickhouseHost=$(aws cloudformation describe-stacks --stack-name $clickhouseStackName --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="ClickhouseDnsHost").OutputValue')
echo $clickhouseHost
yq e -i '.signoz-app.clickhouseConf.hostName |= env(clickhouseHost)' output.yml


echo "succesfully setup a clickhouse cluster"