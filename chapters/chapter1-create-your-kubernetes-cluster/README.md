# Chapter 1: Create Your Kubernetes Cluster

Welcome to Chapter 1 of the **Road To DevOps** YouTube series documentation.
## Prerequisites

Before you begin, make sure you have the following prerequisites in place (or you can use the `prepare-env.sh` script to do it for you!):
- **Oracle Cloud Infrastructure (OCI) Account**: If you don't have one, you can sign up for a [Free Tier Account](https://www.oracle.com/cloud/free/).
- Generate SSH and RSA keys
- Install prerequisite clients:
	- Terraform
	- Python 3.10 (will be required for next chapters) 
	- jq 
	- OCI client 
	- Kubectl 
	- Git
- Create required directories - The guide will be demonstrated using these directories, however you can choose any directory you prefer.
  **This will require manual changes to the provided commands or scripts in case you plan to use them!**

## Quick Overview 

## Full Overview 
### 1. Initial Configuration
To make life easier the `prepare-env.sh` Bash script was created to perform the following:
- Create all required directories
- Generate SSH and RSA Keys
- Install prerequisite clients and commands

To run the bash script you'll need to provide your email address, for example:
```
bash prepare-env.sh daveops.dev@gmail.com
```
:rotating_light: **Disclaimer**: this script was created **ONLY** for MacOS users and won't work for other operating systems.

If you're not following this guide from a MacOS or prefer not to use the Bash scripts, you can follow these steps:
1. **Create directories**:
```
mkdir -p ~/.oci
mkdir -p $HOME/workspace/cloud
```

:rotating_light: **WARNING**: Before Generating any RSA/SSH keys!
In case you have any keys in the `~/.oci` or `~/.ssh` directories, PLEASE CREATE A BACKUP!!!

2. **Create RSA keys**:
```
openssl genrsa -out ~/.oci/${USER}-oracle-cloud.pem 4096
chmod 600 ~/.oci/${USER}-oracle-cloud.pem
openssl rsa -pubout -in ~/.oci/${USER}-oracle-cloud.pem -out ~/.oci/${USER}-oracle-cloud_public.pem
```
The keys will be created under the `~/.oci` directory.

3. **Generating SSH keys**:
```
ssh-keygen -t rsa -b 4096 -C "$email"
```
The keys will be created under the `~/.ssh` directory.

4. **Install the required clients and commands** (you can find the installation for each cli under the `Installation docs` at the bottom of this readme).

### 2. **Cloning the GitHub Repository**:
 - Clone the [K3s on OCI Repository](https://github.com/garutilorenzo/k3s-oci-cluster.git) that contains our project files.
```
cd $HOME/workspace/cloud
git clone https://github.com/garutilorenzo/k3s-oci-cluster.git
```

### 3. **Configuring the OCI CLI - Recommended Method**:
To configure the OCI client, navigate to the OCI console in your browser, from the Profile menu, go to User settings and click API Keys.  
Afterwards, press on the `Add API Key`, select `Paste a public key` and paste the content of the public RSA key we created.  

For MacOS users, you can use `pbcopy` to copy the public key content:
```
cat ~/.oci/$USER-oracle-cloud_public.pem | pbcopy
```

After copying the RSA key and creating the new API Key, you'll have the option to copy the configurations under the `Configuration file preview`.

Copy this section to a new file under `~/.oci/config`. Don't forget to edit the `key_file` to your private key path.  
For example:
`key_file=~/.oci/daveops-oracle-cloud.pem`

To test the OCI client is configured, run the following command:
```
oci iam region list
```

The command should output a JSON list of all regions.

### 4. **Collecting OCI Secrets For Terraform Project tfvars File**:
The **easiest way** to do so is to utilize the `update-tfvars-file.sh` Bash script (**requires the OCI client to be configured as mentioned in step 4**), for example:
```
bash update-tfvars-file.sh
```

This will create the `terraform.tfvars` file under the `$HOME/workspace/cloud/k3s-oci-cluster/example` directory with all the required variables to configure the Terraform project.

The **hard way** to configure the `terraform.tfvars` file is by manually creating it and copying the variables manually, using these steps:
 - Navigate to the repository directory:
```
cd  $HOME/workspace/cloud/k3s-oci-cluster/example
```
 - Create the `terraform.tfvars` file.
 - Add the following lines to the file `terraform.tfvars`:
```
fingerprint = "<Copy the FINGERPRINT from the ~/.oci/config file>"
user_ocid = "<Copy the USER from the ~/.oci/config file>"
private_key_path = "<Copy the key_file from the ~/.oci/config file>"
tenancy_ocid = "<Copy the TENANCY from the ~/.oci/config file>"
compartment_ocid = "<Copy the TENANCY from the ~/.oci/config file>"
region = "<Copy the REGION from the ~/.oci/config file>"
os_image_id = "<Use the command oci compute image list --compartment-id "$tenancy_id" --operating-system 'Canonical Ubuntu' --shape 'VM.Standard.A1.Flex' to find the image ID tag (Recommended - Ubuntu 22.04)>"
availability_domain = "<Run the command 'oci iam availability-domain list' and paste the $name variable>"
cluster_name = "<Set any name you want for your cluster>"
my_public_ip_cidr = "<Run the command 'dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com' to find your public IP and set it with the CIDR of 32, as '123.123.123.123/32'>"
certmanager_email_address = "<Set your email address>"
```

- To collect the required credentials information from the **OCI Console**, you can read the official documentation - https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm

### 5. **Running Terraform Commands**:
From the `$HOME/workspace/cloud/k3s-oci-cluster/example` directory, run the following command to spin up the Kubernetes cluster using the OCI resources:
 - Initialize the Terraform project: `terraform init`.
 - Review the execution plan: `terraform plan`.
 - Apply changes to create the Kubernetes cluster: `terraform apply`.

### 6. **Exploring Terraform Destroy**:
 - Destroy all the OCI resources using: `terraform destroy`.

## Documentation
### Resources
- Terraform Official Documentation: [Getting Started](https://learn.hashicorp.com/tutorials/terraform/aws-build?in=terraform/aws-get-started)
- Oracle Cloud Infrastructure (OCI) Documentation: [Getting Started](https://docs.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
- Garuti Lorenzo's **k3s-oci-cluster** GitHub Repository: [K3s on OCI Repository](https://github.com/garutilorenzo/k3s-oci-cluster.git) :heart:

### Installation docs
Homebrew installation page: https://brew.sh.  
Terraform installation page: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli.  
OCI client installation page: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm.  
Python installation page: https://www.python.org/downloads/.  
Git installation page: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git.  
Kubectl installation page: https://kubernetes.io/docs/tasks/tools/.  
Jq installation page: https://jqlang.github.io/jq/download/.  
