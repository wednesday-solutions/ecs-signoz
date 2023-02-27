aws cloudformation validate-template --template-body file://clickhouse.yaml --no-cli-pager
aws cloudformation create-stack --template-body file://clickhouse.yaml --stack-name clickhouse --no-cli-pager &> /dev/null
aws cloudformation wait stack-create-complete --stack-name clickhouse
vpcId=$(aws cloudformation describe-stacks --stack-name clickhouse --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="VpcId").OutputValue')
echo $vpcId
clickhouseHost=$(aws cloudformation describe-stacks --stack-name clickhouse --output json | jq -r '.Stacks[0].Outputs[] | select(.OutputKey=="ClickhouseDnsHost").OutputValue')
echo $clickhouseHost
exit 0