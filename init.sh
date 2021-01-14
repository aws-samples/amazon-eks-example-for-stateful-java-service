#!/bin/bash
# This simple Bash script is meant to initialize your local environment.
# It does following steps:
#   1. Update local kubeconfig file
#   2. Replace Amazon ElastiCache confighuration in config map
#   3. Build application, build docker image and push to Docker Hub
#   4. Replace docker repository name in deployment

# created by Bastian Klein - basklein@amazon.de
# Disclaimer: NOT FOR PRODUCTION USE - Only for demo and testing purposes

ERROR_COUNT=0;

if [[ $# -lt 1 ]] ; then
    echo 'argument missing, please provide aws dev profile string (-p)'
    exit 1
fi

while getopts ":r:t:u:" opt; do
  case $opt in
    r) REPO="$OPTARG"
    ;;
    t) TAG="$OPTARG"
    ;;
    u) USER="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

if ! [ -x "$(command -v aws)" ]; then
  echo 'Error: aws cli is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker cli is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v mvn)" ]; then
  echo 'Error: mvn is not installed.' >&2
  exit 1
fi

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed.' >&2
  exit 1
fi

# Get EKS Cluster Name of the newly created cluster
EKS_CLUSTER_NAME=$(aws cloudformation list-exports | jq -r '.Exports[] | select(.ExportingStackId | contains("EKSJavaApplication-EKSStack")) | .Value')

# Get the Redis Database Adress
ELASTICACHE_DB_ADDRESS=$(aws cloudformation list-exports | jq -r '.Exports[] | select(.ExportingStackId | contains("EKSJavaApplication-ElastiCacheStack")) | .Value')

[[ -z "$EKS_CLUSTER_NAME" ]] && echo "Could not get EKS Cluster Name" && exit 1
[[ -z "$ELASTICACHE_DB_ADDRESS" ]] && echo "Could not get Elatiscache Address" && exit 1

# Update local kube config to use the newly created cluster
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME

# Update the redsi-web-config-map for the Java Micro Service
sed -i '' -e "s/  host\: \".*\"/  host\: \"${ELASTICACHE_DB_ADDRESS}\"/g" k8s-resources/config-map.yaml

# Build & Package
mvn clean install

# Build docker images and push
docker build -t ${USER}/${REPO}:${TAG} .
docker push ${USER}/${REPO}:${TAG}

# Replace image in deployment
sed -i '' -e "s/        image\: .*/        image\: ${USER}\/${REPO}\:${TAG}/g" k8s-resources/deployment.yaml