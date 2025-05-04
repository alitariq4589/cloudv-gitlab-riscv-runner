#!/bin/bash

RUNNER_REGISTRATION_TOKEN="$1"

# Define the file that stores the RUNNER_ID
RUNNER_ID_FILE="$2/runner_id.txt"

# Check if the RUNNER_ID_FILE exists, if not, create it and set the initial ID to 1
if [ ! -f "$RUNNER_ID_FILE" ]; then
    echo "0" > "$RUNNER_ID_FILE"
fi

# Read the current RUNNER_ID from the file
RUNNER_ID=$(cat "$RUNNER_ID_FILE")

# Increment the RUNNER_ID by 1
NEW_RUNNER_ID=$((RUNNER_ID + 1))


# Next commands are executed via ssh on the RISC-V Device. Be sure to replace the variables with appropriate RISC-V identity file, URI and linux username

# Following command registers the RISC-V Gitlab runner with gitlab project. Make sure the runner is already running as a service

ssh -i $IDENTITY_FILE_PATH  gitlab-runner-user@$RISC_V_URI "LOG_FILE=/home/gitlab-runner-user/user-logs/gitlab_runner_registration_${NEW_RUNNER_ID}.log && RUNNER_REGISTRATION_TOKEN=$RUNNER_REGISTRATION_TOKEN && /home/gitlab-runner-user/gitlab-runner/out/binaries/gitlab-runner-linux-riscv64 register --non-interactive --url \"https://gitlab.com/\" --registration-token \$RUNNER_REGISTRATION_TOKEN --executor \"docker\" --docker-image \"docker:latest\" --tag-list \"riscv,docker,ci\" --run-untagged=\"true\" --locked=\"false\" > \$LOG_FILE 2>&1"

# Following command creates a new file and store the token in it. The purpose of this is that, there is a python script which is run reguarly by cronjob to check if 30 days have passed since this token was created this runner will be unregistered by the python script.

ssh -i $IDENTITY_FILE_PATH gitlab-runner-user@$RISC_V_URI "RUNNER_FILE=/home/gitlab-runner-user/gitlab-runners/runner_${NEW_RUNNER_ID} && RUNNER_REGISTRATION_TOKEN=$RUNNER_REGISTRATION_TOKEN && echo \$RUNNER_REGISTRATION_TOKEN > \$RUNNER_FILE"


# Check if the command was successful, and if so, update the RUNNER_ID in the file
if [ $? -eq 0 ]; then
    echo "Runner registration completed. Log saved!"
    echo "$NEW_RUNNER_ID" > "$RUNNER_ID_FILE"
else
    echo "Runner registration failed. Please check the log file for errors."
fi

