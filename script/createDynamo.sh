#!/bin/bash

# 引数がawsの場合、aws上にDynamoDBのテーブルを削除、作成
# 引数がlocalstackの場合、LocalStack上にS3とDynamoDBを削除、作成

DYNAMO_DB_NAME=coupons
DYNAMO_LS_URL=http://localhost:4569
S3_LS_URL=http://localhost:4572

if [ "$1" == "localstack" ]; then
    DYNAMO_ENDPOINT_URL=${DYNAMO_LS_URL}
elif [ "$1" == "aws" ]; then
    DYNAMO_ENDPOINT_URL=http://dynamodb.ap-northeast-1.amazonaws.com
else
    echo "invalid arguments"
    exit 1
fi

create(){
    if [ "$1" == "localstack" ]; then
        aws s3 mb s3://dev-cpa-s3-coupons --endpoint-url=${S3_LS_URL}
    fi

    echo "=*=*=*=*=*=*= create dynamo db =*=*=*=*=*=*="
    aws dynamodb create-table \
        --table-name ${DYNAMO_DB_NAME} \
        --attribute-definitions \
          AttributeName=id,AttributeType=S \
        --key-schema \
          AttributeName=id,KeyType=HASH \
        --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
        --endpoint-url ${DYNAMO_ENDPOINT_URL}

    aws dynamodb list-tables --endpoint-url ${DYNAMO_ENDPOINT_URL}
    aws dynamodb scan --table-name ${DYNAMO_DB_NAME} --endpoint-url ${DYNAMO_ENDPOINT_URL}
}

clean(){
    echo "=*=*=*=*=*=*= delete dynamo db =*=*=*=*=*=*="
    aws dynamodb delete-table \
        --table-name ${DYNAMO_DB_NAME} \
        --endpoint-url ${DYNAMO_ENDPOINT_URL}

    if [ "$1" == "localstack" ]; then
        echo "delete s3"
        aws s3 rb s3://dev-cpa-s3-coupons --endpoint-url=${S3_LS_URL}
    fi
}

set -x
clean "$1"
echo "=*=*=*=*=*=*= finish clean =*=*=*=*=*=*="
create "$1"
echo "=*=*=*=*=*=*= finish create  =*=*=*=*=*=*="
