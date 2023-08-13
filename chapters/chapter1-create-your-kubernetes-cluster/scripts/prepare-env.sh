#!/bin/bash

echo "###########################################
#### Road To DevOps Preperation Script ####
###########################################"

# Check if the script is running on macOS
if [[ $(uname -s) != "Darwin" ]]; then
    echo "ERROR: This script only works on macOS."
    exit 1
fi

# Check an argument has passed
if [ $# -ne 1 ]; then
    echo "ERROR: Email address argument is required."
    echo "Usage: $ bash $0 daveops.dev@gmail.com"
    exit 1
fi

# Create directories
echo "INFO: Creating Directories."
mkdir -p ~/.oci
mkdir -p ~/.ssh
mkdir -p $HOME/workspace/cloud


# Function for validating the argument is a valid email address
email="$1"
validate_email() {
    if [[ ! "$email" =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$ ]]; then
        echo "ERROR: Invalid email address provided."
        exit 1
    fi
}
validate_email

# Create RSA and SSH keys
rsa_private_key=~/.oci/${USER}-oracle-cloud.pem
rsa_public_key=~/.oci/${USER}-oracle-cloud_public.pem
ssh_private_key=~/.ssh/id_rsa
ssh_public_key=~/.ssh/id_rsa.pub

if [[ ! -f "$rsa_private_key" && ! -f "$rsa_public_key" && ! -f "$ssh_private_key" && ! -f "$ssh_public_key" ]]; then
    echo "INFO: Generating RSA keys under ~/.oci directory."
    openssl genrsa -out "$rsa_private_key" 4096
    chmod 600 "$rsa_private_key"
    openssl rsa -pubout -in "$rsa_private_key" -out "$rsa_public_key"
    
    echo "INFO: Generating SSH keys"
    ssh-keygen -t rsa -b 4096 -C "$email"
else
    echo "WARNING: Some keys already exist in the specified directories."
    read -p "Do you want to overwrite them? (y/n): " overwrite_choice
    case "$overwrite_choice" in
        y|Y|yes|Yes)
            echo "INFO: Generating RSA keys under ~/.oci directory."
            openssl genrsa -out "$rsa_private_key" 4096
            chmod 600 "$rsa_private_key"
            openssl rsa -pubout -in "$rsa_private_key" -out "$rsa_public_key"
            
            echo "INFO: Generating SSH keys"
            ssh-keygen -t rsa -b 4096 -C "$email"
            ;;
        *)
            echo "INFO: Skipping key generation."
            ;;
    esac
fi

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
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
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
install_with_brew "jq" "jq" "jq is already installed." # Install jq
install_with_brew "oci" "oci-cli" "OCI CLI is already installed." # Install OCI CLI
install_with_brew "kubectl" "" "kubectl is already installed." # Install kubectl

echo "
###########################################
#### Environment preparation completed ####
###########################################"
