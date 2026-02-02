#!/bin/bash

SG_ID="sg-07f113264680f4556"
AMI_ID="ami-0220d79f3f480ecf5"
ZONE_ID="Z04979913T03RP44D4M8A"

for instance in $@

do

    instance_id=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text )

    if [ $instance == "frontend" ]; then

        IP=$( 
            aws ec2 describe-instances \
        --instance-ids $instance_id \
        --query 'Reservations[].Instances[].PublicIpAddress' \
        --output text
    )

    else

    

    IP=$( aws ec2 describe-instances \
        --instance-ids $instance_id \
        --query 'Reservations[].Instances[].PrivateIpAddress' \
        --output text
    )

    fi

 echo "IP Address :: $IP"

 aws route53 change-resource-record-sets \
 --hosted-zone-id $ZONE_ID \
 --change-batch '{
    "Comment": "Updating record",
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
}'

done