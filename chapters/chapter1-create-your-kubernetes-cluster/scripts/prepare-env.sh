#!/bin/bash

echo "###########################################
#### Road To DevOps Preperation Script ####
###########################################"

# Check if the script is running on macOS
if [[ $(uname -s) != "Darwin" ]]; then
    echo "ERROR: This script only works on macOS."
    exit 1
fi

# Create directories
echo "INFO: Creating Directories."
mkdir -p ~/.oci
mkdir -p $HOME/workspace/cloud

# Create RSA key
echo "INFO: Generating RSA keys under ~/.oci directory."
openssl genrsa -out ~/.oci/${USER}-oracle-cloud.pem 4096
chmod 600 ~/.oci/${USER}-oracle-cloud.pem
openssl rsa -pubout -in ~/.oci/${USER}-oracle-cloud.pem -out ~/.oci/${USER}-oracle-cloud_public.pem

# Clone GitHub K3s repository
echo "INFO: Cloning K3s repository to $HOME/workspace/cloud."
current_dir=$(pwd)
cd $HOME/workspace/cloud
git clone https://github.com/garutilorenzo/k3s-oci-cluster.git
cd $current_dir

# Install Prerequisites
echo "
##################################
#### Installing Prerequisites ####
##################################"

# Install Homebrew
if ! command -v brew; then
    echo "INFO: Installing Homebrew."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh)"
    brew update
    echo "INFO: Homebrew installed successfully."
else
    echo "INFO: Homebrew is already installed."
fi

# Function to install a tool using Homebrew
install_with_brew() {
    tool_name="$1"
    install_command="$2"
    already_installed_message="$3"

    if ! command -v "$tool_name"; then
        echo "INFO: Installing $tool_name."
        if brew install "$install_command"; then
            echo "INFO: $tool_name installed successfully."
        else
            echo "ERROR: Failed to install $tool_name."
            exit 1
        fi
    else
        echo "INFO: $already_installed_message."
    fi
}

# Install CLIs
install_with_brew "brew" "" "Homebrew is already installed." # Install Homebrew if not installed
install_with_brew "terraform" "hashicorp/tap/terraform" "Terraform is already installed." # Install Terraform
install_with_brew "python3.10" "python@3.10" "Python 3.10 is already installed." # Install Python 3.10
install_with_brew "oci" "oci-cli" "OCI CLI is already installed." # Install OCI CLI
install_with_brew "kubectl" "" "kubectl is already installed." # Install kubectl

echo "
###########################################
#### Environment preparation completed ####
###########################################"
