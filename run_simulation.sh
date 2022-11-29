#!/bin/sh

# 0. Test out the environment variables
echo "S3_INPUT_URI: " $S3_INPUT_URI
echo "S3_OUTPUT_URI: " $S3_OUTPUT_URI

# 1. Get the appropriate python environment
CONDA_DIR=/opt
ENV_NAME=myenv
source "$CONDA_DIR/miniconda/bin/activate"
conda activate $ENV_NAME


# 2. Run the python program
echo "Getting data from S3"
aws s3 cp $S3_INPUT_URI/input.csv /tmp/input.csv
LINE=$((AWS_BATCH_JOB_ARRAY_INDEX + 1))
CMD=$(sed -n ${LINE}p /tmp/simulations.txt)
echo Running the following: $CMD.
echo You are running python version: $(python -V)
python /tmp/myscript.py $CMD
echo "Writing data to S3"
aws s3 sync /tmp/output/ $S3_OUTPUT_URI/
