#!/bin/bash
# This is a simple bash script.
# It basically glues together the parts running in loose coupling during the deployment and helps to speed things up which
# otherwise would have to be noted down and put into the command line.
# This can be migrated into real orchestration / automation toolsets if needed (e.g. Ansible, Puppet or Terraform)

# created by Bastian Klein - basklein@amazon.de
# Disclaimer: NOT FOR PRODUCTION USE - Only for demo and testing purposes

ERROR_COUNT=0;

if [[ $# -lt 2 ]] ; then
    echo 'arguments missing, please the aws profile string (-p) and the deployment Stack Name (-s)'
    exit 1
fi

while getopts ":p:s:" opt; do
  case $opt in
    p) PROFILE="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if ! [ -x "$(command -v aws)" ]; then
  echo 'Error: aws cli is not installed.' >&2
  exit 1
fi

echo "Deleting Kubernetes resource"
echo "##################################################"
kubectl delete -f k8s-resources/

echo "using AWS Profile $PROFILE"
echo "##################################################"

# get the s3 bucket name out of the deployment.
PREPSTACK="DevSourceBucket"
STACK="EKSJavaApplication"
SOURCE=`aws cloudformation describe-stacks --profile=$PROFILE --query "Stacks[0].Outputs[0].OutputValue" --stack-name $PREPSTACK`

SOURCE=`echo "${SOURCE//\"}"`

echo "##################################################"
echo "Truncate the S3 Bucket"
echo "##################################################"
aws s3 rm --profile=$PROFILE s3://$SOURCE --recursive


echo "Delete the Environment"
echo "##################################################"
aws cloudformation delete-stack --profile=$PROFILE --stack-name $STACK

aws cloudformation wait stack-delete-complete --profile=$PROFILE --stack-name $STACK

echo "##################################################"
echo "Deletion finished"

echo "delete the Prerequisites stack"
echo "##################################################"

aws cloudformation delete-stack --stack-name $PREPSTACK --profile=$PROFILE
aws cloudformation wait stack-delete-complete --profile=$PROFILE --stack-name $PREPSTACK

echo "##################################################"
echo "Deletion done"


exit 0