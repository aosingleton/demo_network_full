#!/bin/bash

# Description: Script creates sample demo network environment.  AWS cloud resources are included in the network cloudfomration/network file.

action=$1
varKeyPair=$2
varTempBucket=$3
varProjectName=$4
varProjectStage=$5
currentDataAgain=$(date +"%m%d20%y-%H%M")
varTempCFStackName=${varProjectName}-${varProjectStage}-stack
aws s3 sync cloudformation/ s3://$varTempBucket/cloudformation

echo "...creating parameters file"
echo "
[
    {
        \"ParameterKey\": \"TempEC2KeyPair\",
        \"ParameterValue\": \"$varKeyPair\"
    },
    {
        \"ParameterKey\": \"TemplatesNetwork\",
        \"ParameterValue\": \"https://${varTempBucket}.s3.amazonaws.com/cloudformation/network.yaml\"
    }
]
" > parameters.json

echo "...saving stack name in a file"
echo "
[
    {
        \"ParameterKey\": \"StackName\",
        \"ParameterValue\": \"$varTempCFStackName\"
    }
]
" > stack_name.json

if [ $action == 'create' ]; then
    echo -e "Creating Demo Dashboard Project Resources. \n"
    aws cloudformation $action-stack --stack-name ${varTempCFStackName} --template-body file://$PWD/cloudformation/parent.yaml --capabilities CAPABILITY_IAM CAPABILITY_NAMED_IAM --parameters file://parameters.json
    aws cloudformation wait stack-create-complete --stack-name $varTempCFStackName;
fi

if [ $action == 'remove' ]; then
    echo 'removing cloudformation bucket files'
    aws s3 rm s3://$varTempBucket/cloudformation --recursive

    echo -e "Creating Demo Dashboard Project Resources. \n"
    varName=$(cat stack_name.json | jq '.[0] | .ParameterValue' -r)
    aws cloudformation delete-stack --stack-name ${varTempCFStackName}
    aws cloudformation wait stack-delete-complete --stack-name $varTempCFStackName;
fi