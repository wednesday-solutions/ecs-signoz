#!/usr/bin/env bash
echo "Mappings:"
echo "  RegionMap:"
regions=$(aws ec2 describe-regions --output text --query 'Regions[*].RegionName')
for region in $regions; do
    (
     echo "    $region:"
     AMI=$(aws ec2 copy-image --region $region --source-region ap-southeast-1 --source-image-id ami-004433cbd60c17191  --name clickhouse-3s-backup-22)
     echo "      ami: $AMI"
    )
done