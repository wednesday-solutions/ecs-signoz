#!/usr/bin/env bash
echo "Mappings:"
echo "  RegionMap:"
regions=$(aws ec2 describe-regions --output text --query 'Regions[*].RegionName')
for region in $regions; do
    (
     echo "    $region:"
     AMI=$(aws ec2 copy-image --region $region --source-region ap-southeast-1 --source-image-id ami-019d1278c7da24427  --name clickhouse-v-backup)
     echo "      ami: $AMI"
    )
done