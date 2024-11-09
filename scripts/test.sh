install_aws() {
    echo "Installing AWS CLI..."
    sudo apt-get update
    sudo apt-get install -y curl unzip

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
    fi
}
auth_docker(){
    aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin 703145693148.dkr.ecr.us-east-2.amazonaws.com
}
main(){
    install_aws
    auth_docker
}
main