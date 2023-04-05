clickhouseCluster=$(yq '.signoz-app.clickhouseConf.stackName' signoz-ecs-config.yml)-signoz
echo "This will delete your cloudformation stack"
aws cloudformation delete-stack --stack-name $clickhouseCluster 
aws cloudformation wait stack-delete-complete --stack-name $clickhouseCluster
yq e -i '.signoz-app.clickhouseConf.hostName |= ""' output.yml
rm output.yml