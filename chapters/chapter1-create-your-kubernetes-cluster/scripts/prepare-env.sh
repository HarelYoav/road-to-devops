#!/bin/bash

echo "###########################################
#### Road To DevOps Preperation Script ####
###########################################"

# Verify if running on macOS
if [ "$(uname)" != "Darwin" ]; then
    echo "Error: This script is intended to run on macOS only."
    exit 1
fi

# Create directories
echo "### INFO: Creating Directories."
mkdir -p ~/.oci
mkdir -p $HOME/workspace/cloud

# Create RSA key
echo "### INFO: Generating RSA keys under ~/.oci directory."
openssl genrsa -out ~/.oci/${USER}-oracle-cloud.pem 4096
chmod 600 ~/.oci/${USER}-oracle-cloud.pem
openssl rsa -pubout -in ~/.oci/${USER}-oracle-cloud.pem -out ~/.oci/${USER}-oracle-cloud_public.pem

# Clone GitHub K3s repository
echo "### INFO: Cloning K3s repository to $HOME/workspace/cloud."
cd $HOME/workspace/cloud
git clone https://github.com/garutilorenzo/k3s-oci-cluster.git
cd

# Install Prerequisites
echo "##################################"
echo "#### Installing Prerequisites ####"
echo "##################################"
if ! command -v brew; then
    echo "### INFO: Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/daveops/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
    echo "### INFO: Homebrew installed successfully."
else
    echo "### INFO: Homebrew is already installed."
fi

if ! command -v terraform; then
    echo "### INFO: Installing Terraform."
    brew update
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
    echo "### INFO: Terraform installed successfully."
else
    echo "### INFO: Terraform is already installed."
fi

if ! command -v python3.10; then
    echo "### INFO: Installing Python 3.10."
    brew install python@3.10
    echo "### INFO: Python 3.10 installed successfully."
else
    echo "### INFO: Python 3.10 is already installed."
fi

if ! command -v oci; then
    echo "### INFO: Installing OCI CLI."
    brew update
    brew install oci-cli
    echo "### INFO: OCI CLI installed successfully."
else
    echo "### INFO: OCI CLI is already installed."
fi

echo "###########################################"
echo "#### Environment preparation completed ####"
echo "###########################################"
