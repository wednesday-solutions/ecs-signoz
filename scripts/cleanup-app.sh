#!/bin/bash


export fileName=signoz-ecs-config.yml
[! -z "$environmentName" ] && export fileName=signoz-ecs-config.yml-$environmentName
appName=$(yq '.signoz-app.application-name' $fileName)
echo "This will delete your copilot app,environment and all the services"




[ -z "$appName" ] && echo "No app name argument supplied" && exit 1
AppName="$appName-app"

echo "Do you wish to continue to delete your copilot app and environments?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) copilot app delete $AppName --yes;  break;;
        No ) exit;;
    esac
done

