# Chapter 1: Create Your Kubernetes Cluster

Welcome to Chapter 1 of the **Road To DevOps** YouTube series documentation.
## Prerequisites

Before you begin, make sure you have the following prerequisites in place:

- **Oracle Cloud Infrastructure (OCI) Account**: If you don't have one, you can sign up for a [Free Tier Account](https://www.oracle.com/cloud/free/).

- Install Homebrew:
```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew update
```
Installation documentation: https://brew.sh

- **Terraform**: Install Terraform by following the instructions at the [Terraform Official Website](https://www.terraform.io).
```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```
Installation documentation: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

- **OCI CLI**: Install the Oracle Cloud Infrastructure Command Line Interface by running:
```
brew install oci-cli
```
Installation documentation: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm

- **Python 3.10**: Install Python 3.10 using Homebrew:
```
brew install python@3.10
```
Installation documentation: https://www.python.org/downloads/

- **Git CLI**: Ensure you have Git installed for repository management.
Installation documentation: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

- **kubectl**: Install `kubectl` to interact with Homebrew:
```
brew install kubectl
```
Installation documentation: https://kubernetes.io/docs/tasks/tools/
## Overview

You can utilize the `prepare-env.sh` Bash script by running:
```
bash prepare-env.sh
```
**Disclaimer**: this script was created **ONLY** for MacOS users and won't work for other operating systems.

Steps to configure the local environment:
1. **Create directories**:
```
mkdir -p ~/.oci
mkdir -p $HOME/workspace/cloud
```

2. **Create RSA keys**:
```
openssl genrsa -out ~/.oci/${USER}-oracle-cloud.pem 4096
chmod 600 ~/.oci/${USER}-oracle-cloud.pem
openssl rsa -pubout -in ~/.oci/${USER}-oracle-cloud.pem -out ~/.oci/${USER}-oracle-cloud_public.pem
```
The keys will be created under the `~/.oci` directory.

3. **Cloning the GitHub Repository**:
 - Clone the [K3s on OCI Repository](https://github.com/garutilorenzo/k3s-oci-cluster.git) that contains our project files.
```
cd $HOME/workspace/cloud
git clone https://github.com/garutilorenzo/k3s-oci-cluster.git
```
4. **Configuring the Terraform Project**:
 - Navigate to the repository directory:
```
cd  $HOME/workspace/cloud/k3s-oci-cluster/example
```
 - Configure your Oracle Cloud Infrastructure settings in Terraform by modifying the `terraform.tfvars` file under the `$HOME/workspace/cloud/k3s-oci-cluster/example` directory.
- To collect the required credential information from the **OCI Console**, gather the information accordingly:

**Tenancy OCID**: <tenancy-ocid>
In the top navigation bar, click the Profile menu, go to Tenancy: <your-tenancy> and copy OCID.

**User OCID**: <user-ocid>
From the Profile menu, go to User settings and copy OCID.

**Fingerprint**: <fingerprint>
From the Profile menu, go to User settings and click API Keys.
Press on the `Add API Key` and paste the content of the public RSA key we created, afterwards copy the fingerprint associated with the RSA public key. 
The format is: xx:xx:xx...xx.

**Region**: <region-identifier>
From the top navigation bar, find your region.
From the table in Regions and Availability Domains, Find your region's <region-identifier>. Example: us-ashburn-1.

Collect the following information from your environment.
**Private Key Path**: <rsa-private-key-path>
Path to the RSA private key you made in the Create RSA Keys section.
Example for Oracle Linux: /home/opc/.oci/<your-rsa-key-name>.pem

After collecting all the information you'll need to create the `terraform.tfvars` file under the `$HOME/workspace/cloud/k3s-oci-cluster/example` directory and copy all the information to it, like so:
```
fingerprint      = "<rsa_key_fingerprint>"
private_key_path = "~/.oci/<your_name>-oracle-cloud.pem"
user_ocid        = "<user_ocid>"
tenancy_ocid     = "<tenency_ocid>"
compartment_ocid = "<compartment_ocid>"
```

6. Afterwards, create and fill the **terraform.tfvars** file.
7. **Running Terraform Commands**:
 - Initialize the Terraform project: `terraform init`.
 - Review the execution plan: `terraform plan`.
 - Apply changes to create the Kubernetes cluster: `terraform apply`.

8. **Exploring Terraform Destroy**:
 - Understand how to clean up resources using `terraform destroy`.

## Resources

- Terraform Official Documentation: [Getting Started](https://learn.hashicorp.com/tutorials/terraform/aws-build?in=terraform/aws-get-started)
- Oracle Cloud Infrastructure (OCI) Documentation: [Getting Started](https://docs.oracle.com/en-us/iaas/Content/GSG/Concepts/baremetalintro.htm)
- GitHub Repository: [K3s on OCI Repository](https://github.com/garutilorenzo/k3s-oci-cluster.git)
