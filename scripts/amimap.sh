#!/usr/bin/env bash
echo "Mappings:"
echo "  RegionMap:"
regions=$(aws ec2 describe-regions --output text --query 'Regions[*].RegionName')
for region in $regions; do
    (
    
     AMI2=$(aws ec2 describe-images --region $region --filters Name=name,Values="$1*" Name=architecture,Values=x86_64 | jq -r '.Images |= sort_by(.CreationDate) | .Images | reverse | .[0].ImageId')
     AMI=$(aws ec2 describe-images --region $region --filters Name=name,Values="zookeeper-image*" Name=architecture,Values=x86_64 | jq -r '.Images |= sort_by(.CreationDate) | .Images | reverse | .[0].ImageId')
     echo "     $region:"
     echo "         cami: $AMI2"
     echo "         zami: $AMI"
     aws ec2 modify-image-attribute --image-id $AMI --launch-permission "Add=[{Group=all}]" --region $region
    )
done