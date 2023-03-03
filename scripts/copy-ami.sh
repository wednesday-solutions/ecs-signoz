#!/usr/bin/env bash
echo "Mappings:"
echo "  RegionMap:"
regions=$(aws ec2 describe-regions --output text --query 'Regions[*].RegionName')
for region in $regions; do
    (
     echo "    $region:"
     AMI=$(aws ec2 copy-image --region $region --source-region ap-southeast-1 --source-image-id ami-061381f2b3a3c890e  --name clickhouse-image-3s)
     echo "      ami: $AMI"
    )
done