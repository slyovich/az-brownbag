# Demo Automation
In this repository, you will find source code to build a container-based application hosted on Microsoft Azure cloud. This PoC will deliver a web app hosting solution leveraging Azure Container App, and Docker containers on Linux nodes.

In order to deploy the infrastructure and the container-based application, we use DevOps practices thanks to GitHub actions and automation.

# Architecture
The application used for this demo is composed of a frontend Blazor App, a backend Web Api and a backend-for-frontend proxy, developed in Microsoft .Net C#.

The application uses Azure Active Directory for user authentication folowing the instruction in the [Secure an ASP.NET Core Blazor WebAssembly standalone app with Azure Active Directory](https://learn.microsoft.com/en-us/aspnet/core/blazor/security/webassembly/standalone-with-azure-active-directory?view=aspnetcore-7.0) topic.

The following schema illustrates the architecture used in this demo.

![Architecture](Resources/Architecture%20-%20Landing%20Zone.png)

# Getting Started
Follow the steps described in this section in order to setup your environment enabling you to start deploying the application and apply some changes in order to see your changes deployed automatically using GitHub Actions.

## Initialize Terraform environment
As the whole environment is deployed using [Terraform on Azure](https://learn.microsoft.com/en-us/azure/developer/terraform/overview) scripts, the first step is to provision an Azure Storage Account enabling to store the state file.
The following AZ CLI script helps you to create this storage in your subscription:

    az login --tenant <YOUR-TENANT-ID>
    az account set --subscription <YOUR-SUBSCRIPTION-ID>

    $resourceGroupName = '<YOUR-RESOURCE-GROUP-NAME>'
    $location = '<STORAGE-LOCATION>'
    $storageAccountName = '<YOUR-STORAGE-NAME>'

    # Create terraform storage account
    az storage account create `
        --name $storageAccountName --resource-group $resourceGroupName --location $location `
        --access-tier hot --kind "StorageV2" --sku "Standard_LRS" --https-only `
        --allow-blob-public-access false --allow-cross-tenant-replication false `
        --allow-shared-key-access true  --min-tls-version "TLS1_2" `
        --tags "context=terraform-state"
    
    # Add container for terraform state file
    az storage container create `
        --name "tfstate" `
        --account-name $storageAccountName `
        --resource-group $resourceGroupName `
        --auth-mode key


## Create your landing zone
- VNet
- Log Analytics Workspace + App Insight
- Key Vault + private endpoint
- Front Door (+ custom domain)
- ACA
- GitHub Runner
More information on how to deploy this infrastructure is available [here](IaC/README.md).

## Register your AAD applications 
- App registrations (+ redirect URIs from local and distant)
- Register these apps in Key Vault
- Create schema to explain where these app are references and how they are used

## Configure GitHub secrets
- Azure credentials

## Deploy the application hosting infrastructure
- Terraform pipeline
- Use KeyVault secrets to create ACA secrets
    End of march, public preview (https://github.com/microsoft/azure-container-apps/issues/608)
- Set ACA managed identity
- Grant access to Key Vault to ACA managed identity

## Deploy the application