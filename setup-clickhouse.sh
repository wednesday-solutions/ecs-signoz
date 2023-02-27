#!/bin/bash
aws cloudformation validate-template --template-body file://clickhouse.yaml --no-cli-pager
aws cloudformation create-stack --template-body file://clickhouse.yaml --stack-name clickhouse --no-cli-pager &> /dev/null
aws cloudformation wait stack-create-complete --stack-name clickhouse
export vpcId=$(aws cloudformation describe-stacks --stack-name clickhouse --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="VpcId").OutputValue')
echo $vpcId
export publicSubNetAId=$(aws cloudformation describe-stacks --stack-name clickhouse --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PublicSubNetAId").OutputValue')
echo $publicSubNetAId
export publicSubNetBId=$(aws cloudformation describe-stacks --stack-name clickhouse --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PublicSubNetBId").OutputValue')
echo $publicSubNetBId
export privateSubNetAId=$(aws cloudformation describe-stacks --stack-name clickhouse --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PrivateSubNetAId").OutputValue')
echo $privateSubNetAId
export privateSubNetBId=$(aws cloudformation describe-stacks --stack-name clickhouse --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="PrivateSubNetBId").OutputValue')
echo $privateSubNetBId
export clickhouseHost=$(aws cloudformation describe-stacks --stack-name clickhouse --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="ClickhouseDnsHost").OutputValue')
echo $clickhouseHost

copilot env init --name dev --profile default --import-vpc-id $vpcId --import-private-subnets $privateSubNetAId,$privateSubNetBId --import-public-subnets $publicSubNetAId,$publicSubNetBId
exit 0