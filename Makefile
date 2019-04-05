CFN_STACK_NAME = dev-cpa-couponsApiStack
BUILD_PATH = ./build
S3_BUCKET_COUPONS = dev-cpa-s3-coupons
S3_BUCKET_DEVELOPER = dev-cpa-s3-developer
S3_BUCKET_MATERIALS = dev-cpa-s3-materials
DYNAMO_DB_DATA_FILE = ./initDynamo/dynamoData/initDbData.json

clean:
	-aws s3 rm s3://${S3_BUCKET_COUPONS} --recursive
	aws cloudformation delete-stack --stack-name ${CFN_STACK_NAME}
build:
	-rm -rf ${BUILD_PATH};mkdir -p ${BUILD_PATH}/couponsApi;mkdir -p ${BUILD_PATH}/initDynamo
	cp -r ./couponsApi/app ${BUILD_PATH}/couponsApi/app
	cp -r ./couponsApi/.venv/lib/python3.7/site-packages/* ${BUILD_PATH}/couponsApi
	cp -r ./initDynamo/app ${BUILD_PATH}/initDynamo/app
	cp -r ./initDynamo/.venv/lib/python3.7/site-packages/* ${BUILD_PATH}/initDynamo
deploy: clean build
	aws s3 cp ./couponsApi/swagger/swagger.yaml s3://${S3_BUCKET_DEVELOPER}/swagger.yaml
	sam package --template-file template.yaml --output-template-file packaged.yaml --s3-bucket ${S3_BUCKET_DEVELOPER}
	aws cloudformation deploy --template-file packaged.yaml --stack-name ${CFN_STACK_NAME} --capabilities CAPABILITY_IAM
	aws cloudformation describe-stacks --stack-name ${CFN_STACK_NAME} --query 'Stacks[].Outputs'
hook-initDynamo:
	aws s3 cp ${DYNAMO_DB_DATA_FILE} s3://${S3_BUCKET_COUPONS}/dynamodb/initDbData.json
upload-images:
	aws s3 cp ./materials/pic/qr s3://${S3_BUCKET_MATERIALS}/qr --recursive
	aws s3 cp ./materials/pic/coupon s3://${S3_BUCKET_MATERIALS}/coupon --recursive

.PHONY: all build clean test
