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
	-rm -rf build
	mkdir -p ${BUILD_PATH}; touch ${BUILD_PATH}/__init__.py;
	cp -r ./lambdaFunctions/couponsApi ${BUILD_PATH}
	cp -r ./lambdaFunctions/initDynamo ${BUILD_PATH}
	cp -r ./lambdaFunctions/libs ${BUILD_PATH}
	cp -r ./lambdaFunctions/.venv/lib/python3.7/site-packages/* ${BUILD_PATH}
deploy: clean build
	aws s3 cp ./swagger/swagger.yaml s3://${S3_BUCKET_DEVELOPER}/swagger.yaml
	sam package --template-file template.yaml --output-template-file packaged.yaml --s3-bucket ${S3_BUCKET_DEVELOPER}
	aws cloudformation deploy --template-file packaged.yaml --stack-name ${CFN_STACK_NAME} --capabilities CAPABILITY_IAM
	aws cloudformation describe-stacks --stack-name ${CFN_STACK_NAME} --query 'Stacks[].Outputs'
hook-initDynamo:
	aws s3 cp ${DYNAMO_DB_DATA_FILE} s3://${S3_BUCKET_COUPONS}/dynamodb/initDbData.json
upload-images:
	aws s3 cp ./materials/pic/qr s3://${S3_BUCKET_MATERIALS}/qr --recursive
	aws s3 cp ./materials/pic/coupon s3://${S3_BUCKET_MATERIALS}/coupon --recursive

.PHONY: all build clean test
