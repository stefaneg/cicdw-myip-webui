#!/usr/bin/env bash

. ./bashfunctions

set -e

export INFRASTRUCTURE_STACK_NAME=$1
export WEB_API_BRANCH_NAME=$2
export BRANCH_NAME=$3

requireVariable INFRASTRUCTURE_STACK_NAME
requireVariable WEB_API_BRANCH_NAME
requireVariable BRANCH_NAME


export WEB_API_STACK_NAME=myip-${WEB_API_BRANCH_NAME}


if [ -z "${BRANCH_NAME}" ]; then
	export BRANCH_NAME=master
fi

WEB_BUCKET_REGION=eu-west-1

export WEB_BUCKET_NAME=$(aws cloudformation describe-stacks --region eu-west-1 --stack-name ${INFRASTRUCTURE_STACK_NAME} --query "Stacks[0].Outputs[?OutputKey=='webDeploymentBucketName'].OutputValue" --output text)

export WEB_API_ENDPOINT=$(aws cloudformation describe-stacks --region eu-west-1 --stack-name ${WEB_API_STACK_NAME} --query "Stacks[0].Outputs[?OutputKey=='apiGatewayInvokeURL'].OutputValue" --output text)

echo "Deploying to bucket ${WEB_BUCKET_NAME}"

cat index.html | envsubst | aws s3 cp - s3://${WEB_BUCKET_NAME}/${BRANCH_NAME}/index.html --acl public-read --cache-control no-cache --content-type text/html

export WEB_URI="https://${WEB_BUCKET_NAME}.s3-${WEB_BUCKET_REGION}.amazonaws.com/${BRANCH_NAME}/index.html"

echo "Deployed to ${WEB_URI}"


if [[ $- == *i* ]]
then
	echo Opening webui ${WEB_URI}
	open ${WEB_URI}
else
	echo "Checking if index.html is accessible on endpoint ${WEB_URI}"

	STATUSCODE=$(curl -I ${WEB_URI}  2>/dev/null | head -n 1| cut -d$' ' -f2)
	if [[ ! ${STATUSCODE} = "200" ]]; then
		echo "Unable to fetch web page, status code ${STATUSCODE}"
		exit -1
	else
		echo "curl got status code ${STATUSCODE}"
	fi
fi

