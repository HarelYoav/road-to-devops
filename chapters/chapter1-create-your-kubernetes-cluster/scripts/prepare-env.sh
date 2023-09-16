#!/bin/bash

echo "###########################################
#### Road To DevOps Preperation Script ####
###########################################"

OS=""
# Check the OS the script is running on
if [[ $(uname -s) == "Darwin" ]]; then
    echo "Detected macOS installation mode."
    OS="Darwin"
elif [[ $(uname -s) == "Linux" &&  $(grep -oP 'NAME="\K[^"]+' /etc/os-release | head -n1 | sed -e 's/\s.*$//') == "Ubuntu" ]]; then 
    echo "Detected Ubuntu Linux installation mode."
    OS="Ubuntu"
else
    echo "ERROR: This script only works on macOS or Ubuntu."
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

# Function to install a tool using Homebrew
install_cli_tool() {
    tool_name="$1"
    install_command="$2"

    if [ -n "$tool_name" ] && command -v "$tool_name" &>/dev/null; then
        echo "INFO: $tool_name is already installed."
    else
        echo "INFO: Installing $tool_name."
        if eval "$install_command"; then
            echo "INFO: $tool_name installed successfully."
        else
            echo "ERROR: Failed to install $tool_name."
            exit 1
        fi
    fi
}

# Install Prerequisites for macOS
install_on_macOS() {
    # Install CLIs
    install_cli_tool "brew" '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"' # Install Homebrew if not installed
    install_cli_tool "terraform" "brew install hashicorp/tap/terraform" # Install Terraform
    install_cli_tool "python3.10" "brew install python@3.10" # Install Python 3.10
    install_cli_tool "jq" "brew install jq" # Install jq
    install_cli_tool "oci" "brew install oci-cli" # Install OCI CLI
    install_cli_tool "kubectl" 'curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"; chmod +x kubectl; sudo mv kubectl /usr/bin' # Install kubectl
}

# Install Prerequisites for Linux (Ubuntu)
install_on_Ubuntu() {
    # Install CLIs
    install_cli_tool "sudo" "apt-get update && apt-get -y install sudo"
    install_cli_tool "add-apt-repository" "export DEBIAN_FRONTEND=noninteractive; apt-get -y install tzdata; sudo apt-get -y install software-properties-common"
    install_cli_tool "python3.10" "sudo add-apt-repository -y ppa:deadsnakes/ppa; sudo apt update; sudo apt-get install -y python3.10"
    install_cli_tool "pip" "sudo apt -y install python3-pip"
    install_cli_tool "jq" "sudo apt-get install -y jq" "jq is already installed."
    install_cli_tool "curl" "sudo apt install -y curl" "curl is already installed."
    install_cli_tool "unzip" "sudo apt-get install -y unzip" "unzip is already installed."
    install_cli_tool "Terraform" 'curl -LO "https://releases.hashicorp.com/terraform/$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')/terraform_$(curl -s https://checkpoint-api.hashicorp.com/v1/check/terraform | jq -r -M '.current_version')_linux_amd64.zip"; unzip terraform_*_linux_amd64.zip && rm terraform_*_linux_amd64.zip; sudo mv terraform /usr/bin'
    install_cli_tool "kubectl" 'curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; chmod +x kubectl; sudo mv kubectl /usr/bin'
    install_cli_tool "oci" 'curl -LO "https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh"; chmod +x install.sh; sudo ./install.sh --install-dir /opt/oracle/cli --exec-dir /usr/bin --accept-all-defaults; sudo rm install.sh'
}

#Check OS type
case $OS in

  "Ubuntu")
    install_on_Ubuntu
    ;;

  "Darwin")
    install_on_macOS
    ;;

  *)
    exit 1
    ;;
esac

echo "
###########################################
#### Environment preparation completed ####
###########################################"
