#!/bin/bash

SG_ID="sg-0cf89fb7f592b1fe1" 
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z00603943PQ4GRTFDYEL7"
DOMAIN_NAME="avyunan.fun"

for instance in $@
do
   Instance_id=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-id $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text )

    if [ $instance == "frontend" ]; then
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $Instance_id \
            --query 'Reservations[*].Instances[*].PublicIpAddress' \
            --output text
        )
        RECORD_NAME="frontend.$DOMAIN_NAME" # frontend.avyunan.fun
    else
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $Instance_id \
            --query 'Reservations[*].Instances[*].PrivateIpAddress' \
            --output text
        )
        RECORD_NAME="$instance.$DOMAIN_NAME" # mongo.avyunan.fun
    fi

    echo "IP ADDRESS : $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch '
        {
        "Comment": "Updating A record",
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$RECORD_NAME'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
        }

    '

    echo "record update properly for $instance"

done

