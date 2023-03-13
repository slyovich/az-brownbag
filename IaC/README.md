# How to run your scripts

## Run locally

### Login to Azure
The first step is to login to your Azure tenant and switch your context to the subscription where you want to deploy your infrastructure.

    az login --tenant "<YOUR-TENANT-ID>"
    az account set --subscription "<YOUR-SUBSCRIPTION-ID>"

### Select your area
Depending on which script you want to execute, navigate to the corresponding folder. Example with the landing zone script.

    cd ./landing-zone

### Initialize terraform
First of all, we need to initiatize the terraform environment. This step is executed at start, or as soon as a new module was created or moved. Execute the following command to initialize your environment.
    
    terraform init

In case you want to store your terraform state on an Azure storage account to avoid keeping the state file locally, you can use the following command.
For that, you must first create a service principal as explained [in terraform documentation](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/guides/service_principal_client_secret) and obtain the client id and client secret, used for authentication.

    terraform init `
        -backend-config=storage_account_name="<YOUR-STORAGE-ACCOUNT-NAME>" `
        -backend-config=container_name="<YOUR-CONTAINER-NAME>" `
        -backend-config=key=backend.tfstate `
        -backend-config=resource_group_name="<RESOURCE-GROUP-NAME-WHERE-STORAGE-EXISTS>" `
        -backend-config=subscription_id="<SUBSCRIPTION-ID-WHERE-STORAGE-EXISTS>" `
        -backend-config=tenant_id="<TENANT-ID-WHERE-STORAGE-EXISTS>" `
        -backend-config=client_id="<APP-REGISTRATION-ID>" `
        -backend-config=client_secret="<APP-REGISTRATION-SECRET>"

### Validate your script
Before executing any action with your code, validate that your script is correct using the following command.

    terraform validate

### Security IaC analysis
When your script is validated, a good practice is to perform a static security analysis on your code. Using [tfsec](https://aquasecurity.github.io/tfsec/v1.28.1/), we can execute scanning of our terraform code. Execute the following command to start your static code analysis.

    tfsec --tfvars-file testing.tfvars

### Plan your execution
Create a local file (called here testing.tfvars) with all variable values related to your environment. Then, execute the following command.

    terraform plan -out='tfuat_plan.binary' -var-file="testing.tfvars"

### Estimate cost
You can use [infracost](https://www.infracost.io/docs) to estimate cloud cost related to your changes. This can be done by executing the following command.

    # Create plan result as json file
    terraform show -json tfuat_plan.binary > tfuat_plan.json

    # Generate cost estimates html report
    infracost breakdown --path tfuat_plan.json --format html > uat_cost.html

### Apply your changes
Execute the following command to apply your changes in your Azure environment.

    terraform apply "tfuat_plan.binary"
