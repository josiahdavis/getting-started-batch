# Running Array Jobs in AWS Batch with Read/Write to S3

The initial motivation for learning AWS batch was to scale out a large-scale simulation. This is a toy example to demonstrate the minumum capability for such an application:

* Using array jobs.
* A python program is running with a different set of arguments for each job.
* There are inputs read from S3 at runtime.
* At the end of the job, data is written to S3.

## 0. Build a container image

This container should have the code you will use as well as the text file with the various arguments.

```
./build_and_push.sh
```

## 1. Create the job queue and compute environment

The compute environment is where you place limits on the type of compute that you will use. The job queue includes a reference the compute environment. You can have multiple compute environments within a single queue.

- [ ] Add in IAM role Batch service (needs AWSBatchServiceRole, AmazonS3FullAccess).
- [ ] Add IAM role for EC2 instance (needs AmazonS3FullAccess, AmazonEC2ContainerServiceforEC2Role).

```
aws batch create-compute-environment --cli-input-json file://simulation-compute-environment.json
aws batch create-job-queue --cli-input-json file://simulation-job-queue.json
```


## 2. Create and register a job definition

As the name implies, the job definition specifies the container image you will use and the compute resources (Memory, CPU) you need for each job.

- [ ] Add in the s3 input and output locations here.

```
aws batch register-job-definition --cli-input-json file://run-simulation-job-def.json
```

## 3. Submit an AWS Batch array job

- [ ] Add in security groups for EC2 instances
- [ ] Input VPC subnets
- [ ] Add in image name

The job points to the job definition, as well as the job queue.

```
aws batch submit-job --cli-input-json file://run-simulation-job.json
```

You can check on the job using the following:
```
job_id=<insert job id here>
aws batch describe-jobs --jobs $job_id | jq '.jobs [] | .status'
```

Reference: https://docs.aws.amazon.com/batch/latest/userguide/array_index_example.html