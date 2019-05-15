#!/bin/bash

#First check latest Amazon Linux 2 image
AMI=$(aws ec2 describe-images --owners amazon --filters 'Name=name,Values=amzn2-ami-hvm-2.0.????????-x86_64-gp2' 'Name=state,Values=available' --output json | jq -r '.Images | sort_by(.CreationDate) | last(.[]).ImageId')
echo $AMI

# Skapa en security group
MySG="MyTestSG14"
aws ec2 create-security-group --group-name $MySG --description $MySG
aws ec2 authorize-security-group-ingress --group-name $MySG  --protocol tcp --port 22 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name $MySG  --protocol tcp --port 80 --cidr 0.0.0.0/0
my_groupid=$(aws ec2 describe-security-groups --group-names $MySG | jq -r '.SecurityGroups[0].GroupId')

# Skapa en ny nyckel
mykeyname="MyNewLoginKey5"
aws ec2 create-key-pair --key-name $mykeyname

# Använd default subnet
mySub=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-7fc1fb19" | jq -r '.Subnets[0].SubnetId')

# Min userdata, skapa en mapp i den sökvägen och döp den till my_userdata
userdatascript="file:///home/ec2-user/environment/my_userdata"

#Run this command för att skapa instansen med UserData
aws ec2 run-instances --image-id $AMI --count 1 --instance-type t2.micro --key-name $mykeyname --security-group-ids $my_groupid --user-data $userdatascript --subnet-id $mySub --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=LAB-Nginx}]' 

# Manuell hantering:
#aws ec2 run-instances --image-id ami-07683a44e80cd32c5 --count 1 --instance-type t2.micro --key-name MyLoginKey --user-data file://my_userdata --subnet-id subnet-e559e8bf --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=MyTestEnv1}]' 