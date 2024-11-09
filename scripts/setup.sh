#!/bin/bash

# Define log file location
echo "Shell Script detected."

set -euxo pipefail

install_docker() {
    sudo apt-get update -y && sudo apt-get upgrade -y
    echo "Installing docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh   
    echo "Successfully Installed docker"
}

install_gcloud() {
    echo "Installing gcloud CLI..."
    curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-linux-x86_64.tar.gz
    tar -xf google-cloud-cli-linux-x86_64.tar.gz
    ./google-cloud-sdk/install.sh --path-update=true --usage-reporting=false --quiet
    source ./google-cloud-sdk/path.bash.inc
    # ./google-cloud-sdk/bin/gcloud init
    echo "gcloud installed Successfully"
}

install_aws() {
    echo "Installing AWS CLI..."
    sudo apt-get update
    sudo apt-get install -y curl unzip jq  # Install jq here

    # Download and install AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    sudo rm -rf awscliv2.zip

    # Verify AWS CLI installation
    if command -v aws &> /dev/null; then
        echo "AWS CLI installed successfully."
    else
        echo "AWS CLI installation failed."
        exit 1
    fi

    # Check if AWS credentials file exists and configure AWS CLI
    if [[ -f "/tmp/aws-creds.json" ]]; then
        echo "Configuring AWS credentials from file..."

        # Extract credentials from aws-creds.json and set them as environment variables
        AWS_ACCESS_KEY_ID=$(jq -r '.AWS_ACCESS_KEY_ID' /tmp/aws-creds.json)
        AWS_SECRET_ACCESS_KEY=$(jq -r '.AWS_SECRET_ACCESS_KEY' /tmp/aws-creds.json)
        AWS_DEFAULT_REGION=$(jq -r '.AWS_DEFAULT_REGION' /tmp/aws-creds.json)

        export AWS_ACCESS_KEY_ID
        export AWS_SECRET_ACCESS_KEY
        export AWS_DEFAULT_REGION

        # Verify AWS CLI configuration
        # aws configure list
    else
        echo "AWS credentials file not found."
        exit 1
    fi

    # Authenticate Docker with AWS ECR
    echo "Authenticating Docker with AWS ECR..."
    aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin 703145693148.dkr.ecr.us-east-2.amazonaws.com

    # Pull Docker image from AWS ECR
    echo "Pulling Docker image from AWS ECR..."
    # docker pull 703145693148.dkr.ecr.us-east-2.amazonaws.com/yeedu_cfe:v2.9.5-rc1  
    # docker pull 703145693148.dkr.ecr.us-east-2.amazonaws.com/yeedu_reactive_actors:v4.13.1-rc15  
    # docker pull 703145693148.dkr.ecr.us-east-2.amazonaws.com/yeedu_spark:v3.4.3-rc2
    docker pull 703145693148.dkr.ecr.us-east-2.amazonaws.com/yeedu_telegraf:1.28.2
    echo "Docker images pulled successfully."
}

install_azcopy() {
    echo "Installing azcopy..."
    curl -sSL -O https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    rm packages-microsoft-prod.deb
    sudo apt-get update
    sudo apt-get install -y azcopy
    echo "azcopy installed successfully"
}

install_az_cli() {
    echo "Installing Azure CLI..."
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    echo "az cli installed successfully"
}

install_fluentd(){
    echo "Installing fluentd..."
    curl -fsSL https://toolbelt.treasuredata.com/sh/install-ubuntu-jammy-fluent-package5-lts.sh | sh
    echo "fluentd installed successfully"
}
  
install_cloudwatch(){
    echo "Installing cloudwatch..."
    curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
    sudo apt update -y
    sudo apt-get install python2 -y
    # sudo apt-get install -y python2.7
    create_aws_cloudwatch_conf_file
    sudo python2 ./awslogs-agent-setup.py -c /tmp/awslogs.conf --region us-east-2 -n
    echo "cloudwatch installed successfully"
}

create_aws_cloudwatch_conf_file() {

  tee /tmp/awslogs.conf <<EOF
[general]
state_file = /var/awslogs/state/agent-state
[/yeedu/bootstrap/logs/bootstrap.log]
datetime_format = %Y-%m-%d %H:%M:%S
file = /yeedu/bootstrap/logs/bootstrap.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = yeedu_boostrap_log
[/yeedu/bootstrap/logs/unstructured-log.log]
datetime_format = %Y-%m-%d %H:%M:%S
file = /yeedu/bootstrap/logs/unstructured-log.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = yeedu_unstructured_log
[/tmp/usi_reactor_logs.log]
datetime_format = %Y-%m-%d %H:%M:%S
file = /tmp/usi_reactor_logs.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = usi_reactor_logs
[/tmp/yeedu_log_collector_reactors.log]
datetime_format = %Y-%m-%d %H:%M:%S
file = /tmp/yeedu_log_collector_reactors.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = yeedu_log_collector_reactors
[/tmp/yeedu_log_collector_history_server.log]
datetime_format = %Y-%m-%d %H:%M:%S
file = /tmp/yeedu_log_collector_history_server.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = yeedu_log_collector_history_server
[/tmp/yeedu_copy_object_storage_logs.log]
datetime_format = %Y-%m-%d %H:%M:%S
file = /tmp/yeedu_copy_object_storage_logs.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = yeedu_copy_object_storage_logs
[/tmp/yeedu_sync_object_storage_logs.log]
datetime_format = %Y-%m-%d %H:%M:%S
file = /tmp/yeedu_sync_object_storage_logs.log
buffer_duration = 5000
log_stream_name = {instance_id}
initial_position = start_of_file
log_group_name = yeedu_sync_object_storage_logs
EOF

}


main() {
    # lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
    # df -h
    install_docker
    # install_gcloud
    install_aws
    # install_azcopy
    # install_az_cli
    # install_fluentd
    # install_cloudwatch
    # install_cuda_drivers
    # install_law
}

# main > "$LOG_FILE" 2>&1
main
