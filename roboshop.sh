#! /bin/bash

SG_ID="sg-07f113264680f4556"
AMI_ID="ami-0220d79f3f480ecf5"

for instance in $@

do

instance_id=$( aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type "t3.micro" \
    --security-group-ids $SG_ID \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    )

    if [ $instance == "frontend" ]; then

        IP=$( aws ec2 describe-instances \
        --instance-ids $instance_id \
        --query 'Reservations[*].Instances[*].PublicIpAddress' \
        )

    else

    

        IP=$( aws ec2 describe-instances \
        --instance-ids $instance_id \
        --query 'Reservations[*].Instances[*].PrivateIpAddress' \
        )

    fi

 echo "IP Address :: $IP"

done