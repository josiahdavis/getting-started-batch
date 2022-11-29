#!/bin/sh

image=python-code

echo "\n1. Building container image.."
docker build --platform linux/amd64 -t "${image}" .

echo "\n2. Running local test"
AWS_BATCH_JOB_ARRAY_INDEX=0
while [ $AWS_BATCH_JOB_ARRAY_INDEX -le 3 ]
do
    docker run --platform linux/amd64 \
        -v ~/.aws:/root/.aws \
        -e AWS_BATCH_JOB_ARRAY_INDEX=$AWS_BATCH_JOB_ARRAY_INDEX \
        -e S3_INPUT_URI=s3://uss-ce-simulation-devo/temp-testing-batch/input \
        -e S3_OUTPUT_URI=s3://uss-ce-simulation-devo/temp-testing-batch/output \
        $image
    AWS_BATCH_JOB_ARRAY_INDEX=$((AWS_BATCH_JOB_ARRAY_INDEX + 1))
done

echo "Do you want to write image to ECR? (y/n):"
read write_image
if [ "$write_image" == "n" ]
then
    echo "Stopping"
    exit 1
fi

echo "\n3. Pushing image to Amazon ECR"

account=$(aws sts get-caller-identity --query Account --output text)
region=$(aws configure get region)

# Login to ecr
aws ecr get-login-password --region ${region} | docker login --username AWS \
    --password-stdin "${account}.dkr.ecr.${region}.amazonaws.com"

# If the repository doesn't exist in ECR, create it.
aws ecr describe-repositories --repository-names "${image}" > /dev/null 2>&1
if [ $? -ne 0 ]
then
    aws ecr create-repository --repository-name "${image}" > /dev/null
fi

docker tag "${image}" "${account}.dkr.ecr.${region}.amazonaws.com/${image}"
docker push "${account}.dkr.ecr.${region}.amazonaws.com/${image}"