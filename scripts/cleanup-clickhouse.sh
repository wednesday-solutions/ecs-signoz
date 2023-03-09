clickhouseCluster=$(yq '.signoz-app.clickhouse-stack-name' signoz-ecs-config.yml)-signoz
echo "This will delete your cloudformation stack"
aws cloudformation delete-stack --stack-name $clickhouseCluster 
aws cloudformation wait stack-delete-complete --stack-name $clickhouseCluster
yq -i e '.signoz-app.clickhouse-host-name |= ""' signoz-ecs-config.yml