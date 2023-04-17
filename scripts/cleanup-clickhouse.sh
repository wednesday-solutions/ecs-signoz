
export fileName=signoz-ecs-config.yml
[! -z "$environmentName" ] && export fileName=signoz-ecs-config-$environmentName.yml

clickhouseCluster=$(yq '.signoz-app.clickhouseConf.stackName' $fileName)-signoz
echo "This will delete your cloudformation stack"
aws cloudformation delete-stack --stack-name $clickhouseCluster 
aws cloudformation wait stack-delete-complete --stack-name $clickhouseCluster
yq e -i '.signoz-app.clickhouseConf.hostName |= ""' output.yml
rm output.yml