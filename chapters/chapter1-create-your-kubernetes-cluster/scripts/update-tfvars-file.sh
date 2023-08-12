#!/bin/bash

# Function to append a line if it doesn't exist in the tfvars file
append_values() {
    local line_to_append="$1"
    local tfvars_file="$2"

    if ! grep -qF "$line_to_append" "$tfvars_file"; then
        echo "$line_to_append" >> "$tfvars_file"
        echo "INFO: Appended - $line_to_append"
    else
        echo "WARN: Skipping line, already exists - $line_to_append"
    fi
}

# Display header
echo "
######################################
#### Update terraform.tfvars file ####
######################################
"

# Define the variables
terraform_project_dir="/Users/$USER/workspace/cloud/k3s-oci-cluster/example"
tfvars_file="$terraform_project_dir/terraform.tfvars"

# Verify k3s-oci-cluster repository exists
if [ ! -d "$terraform_project_dir" ]; then
    echo "Error: Directory '$terraform_project_dir' does not exist."
    exit 1
fi

# Verify if OCI CLI is installed
if ! command -v oci &> /dev/null; then
    echo "Error: OCI CLI is not installed. Please install it and configure your credentials."
    exit 1
fi

# Verify if OCI CLI config file exists
if [ ! -f "$HOME/.oci/config" ]; then
    echo "Error: ~/.oci/config does not exist."
    exit 1
fi

# Verify if OCI CLI configuration is valid
OCI_CONFIG=~/.oci/config oci iam region list &> /dev/null
if [ $? -ne 0 ]; then
    echo "Error: OCI CLI configuration is not valid or unable to retrieve region list.
INFO: For more information, read https://github.com/davidpinhas/road-to-devops/blob/master/chapters/chapter1-create-your-kubernetes-cluster/README.md#4-optional-configuring-the-oci-cli---recommended"
    exit 1
fi

# Create terraform.tfvars file under the k3s-oci-cluster/example directory
if [ ! -f "$tfvars_file" ]; then
    touch "$tfvars_file"
    echo "Created $tfvars_file"
else
    echo "INFO: $tfvars_file already exists"
fi

# Use the append_values function to handle tfvars file
append_values 'fingerprint = "'$(grep '^fingerprint=' ~/.oci/config | cut -d'=' -f2)'"' "$tfvars_file"
append_values 'user_ocid = "'$(grep '^user=' ~/.oci/config | cut -d'=' -f2)'"' "$tfvars_file"
append_values 'private_key_path = "'$(grep '^key_file=' ~/.oci/config | cut -d'=' -f2)'"' "$tfvars_file"
append_values 'tenancy_ocid = "'$(grep '^tenancy=' ~/.oci/config | cut -d'=' -f2)'"' "$tfvars_file"
append_values 'availability_domain = "'$(oci iam availability-domain list | jq '.data[0].name' | cut -d '"' -f2)'"' "$tfvars_file"
append_values 'compartment_ocid = "'$(grep '^tenancy=' ~/.oci/config | cut -d'=' -f2)'"' "$tfvars_file"
append_values 'cluster_name = "test-cluster"' "$tfvars_file"
append_values 'my_public_ip_cidr = "'$(dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com | cut -d '"' -f2)'/32"' "$tfvars_file"
tenancy_id=$(grep '^tenancy=' ~/.oci/config | cut -d'=' -f2)
image_id=$(oci compute image list --compartment-id "$tenancy_id" --operating-system 'Canonical Ubuntu' --shape 'VM.Standard.A1.Flex' | grep 'Canonical-Ubuntu-22.04' -A2 | grep id | head -n1 | cut -d'"' -f4)
append_values "os_image_id = \"$image_id\"" "$tfvars_file"

append_values 'certmanager_email_address = "daveops.dev@gmail.com"' "$tfvars_file"
append_values 'region = "'$(grep '^region=' ~/.oci/config | cut -d'=' -f2)'"' "$tfvars_file"