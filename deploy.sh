#!/bin/bash -x

# Description: Script creates sample demo network environment.  AWS cloud resources are included in the network cloudfomration/network file.

action=$1
varStage=$2
varKeyPair=$3
currentDate=$(date +"%m%d20%y.%H%M")

# resource variables (s3 bucket name, local CF dir, stack name)
varTempBucket=astempbucket$currentDate
varCFBucketLocation=$PWD/correctYaml
varTempCFStackName=${varStage}TempCFStackName071719

# creating cloudformation bucket
aws s3api create-bucket --bucket $varTempBucket
syncing s3 bucket with local CF directory correctYaml
aws s3 sync $varCFBucketLocation s3://$varTempBucket

echo "...creating parameters file"
echo "
[
    {
        \"ParameterKey\": \"TemplatesNetwork\",
        \"ParameterValue\": \"$varKeyPair\"
    },
    {
        \"ParameterKey\": \"TemplatesNetwork\",
        \"ParameterValue\": \"https://${varTempBucket}.s3.amazonaws.com/network.yaml\"
    }
]
" > parameters.json


if [ $action == 'create' ]; then
    echo -e "Creating Demo Dashboard Project Resources. \n"
    aws cloudformation $action-stack --stack-name ${varTempCFStackName} --template-body file://$PWD/cloudformation/parent.yaml --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --parameters file://parameters.json
    aws cloudformation wait stack-create-complete --stack-name $varTempCFStackName;
fi

if [ $action == 'remove' ]; then
    echo -e "Creating Demo Dashboard Project Resources. \n"
    aws cloudformation delete-stack --stack-name ${varTempCFStackName}
    aws cloudformation wait stack-delete-complete --stack-name $varTempCFStackName;
fi