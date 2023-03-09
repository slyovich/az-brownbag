# Demo Automation
In this repository, you will find source code to build a container-based application hosted on Microsoft Azure cloud. This PoC will deliver a web app hosting solution leveraging Azure Container App, and Docker containers on Linux nodes.

In order to deploy the infrastructure and the container-based application, we use DevOps practices thanks to GitHub actions and automation.

# Architecture
The application used for this demo is composed of a frontend Blazor App, a backend Web Api and a backend-for-frontend proxy, developed in Microsoft .Net C#.

The application uses Azure Active Directory for user authentication folowing the instruction in the [Secure an ASP.NET Core Blazor WebAssembly standalone app with Azure Active Directory](https://learn.microsoft.com/en-us/aspnet/core/blazor/security/webassembly/standalone-with-azure-active-directory?view=aspnetcore-7.0) topic.

The following schema illustrates the architecture used in this demo.

![Architecture](Resources/Architecture-Target%20architecture.png)

# Software architecture
Our software architecture is based on a request routing in Backend for Frontend (BFF) scenarios. This means that we built a reverse proxy used to re-route requests from frontend application via BFF to destination API endpoint. BFF layer is protected with cookie based authentication so "No tokens in browser" can be applied. Basically reverse proxy functionality of BFF layer extracts access token from the cookie and passes it further to destination API endpoint. The reverse proxy is implemented using [YARP](https://microsoft.github.io/reverse-proxy/) middleware.
This architecture is based on the blog [How to implement request routing for BFF with YARP](https://www.kallemarjokorpi.fi/blog/request-routing-in-bff.html).

The following schema illustrates the communication flow between the frontend client (running in the browser), the reverse proxy and the backend API.

![Request routing](Resources/Architecture-Request%20Routing.png)

# Getting Started
Follow the steps described in this section in order to setup your environment enabling you to start deploying the application and apply some changes in order to see your changes deployed automatically using GitHub Actions.

## Azure Applications Registrations
As we have two services that perform user authorization based on a token emitted by the Azure Active Directory, we need to register these services as application in Azure App Registrations. One of these applications (Backend for Frontend) uses the [OAuth 2.0 on behalf-of flow](https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-oauth2-on-behalf-of-flow) to authenticate requests to the downstream API Endpoint, we need also to generate an secret for this application.

These applications are registered through [code](IaC/app-registrations/) using AZ CLI. Update the script [main.ps1](IaC/app-registrations/main.ps1) and ensure to copy the returned values and store them as repository variables and secrets (in my case APP_REGISTRATION_CLIENTID_FOR_API, APP_REGISTRATION_CLIENTID_FOR_BFF and APP_REGISTRATION_SECRET_FOR_BFF). You will use these information when deploying your container infrastructure using GitHub Actions.

## Initialize GitHub and Terraform environment
In order to run your GitHub actions authenticated with a service principal, you must create this service principal using the following commands:

    az login --tenant <YOUR-TENANT-ID>
    az account set --subscription <YOUR-SUBSCRIPTION-ID>

    $appName = "GitHub-Action-Deploy"
    
    az ad sp create-for-rbac `
        --name $appName `
        --role Owner `
        --scope "/subscriptions/<YOUR-SUBSCRIPTION-ID>" `
        --sdk-auth

Then, using the output results, create the following JSON object and add this as a GitHub Secret called AZURE_CREDENTIALS.

    {
        "clientId": "<GUID>",
        "clientSecret": "<PrincipalSecret>",
        "subscriptionId": "<GUID>",
        "tenantId": "<GUID>"
    }

In order to use this identity with terraform backend, create one secret for clientId, one for clientSecret and so on, as illustrated in the image below. This will enable you to create environment variables with same name to authenticate your terraform backend configuration.

![GitHub Secrets](./Resources/GitHub-Secrets.png)

As the whole environment is deployed using [Terraform on Azure](https://learn.microsoft.com/en-us/azure/developer/terraform/overview) scripts, the first step is to provision an Azure Storage Account enabling to store the state file.
The following AZ CLI script helps you to create this storage in your subscription:

    $resourceGroupName = '<YOUR-RESOURCE-GROUP-NAME>'
    $location = '<STORAGE-LOCATION>'
    $storageAccountName = '<YOUR-STORAGE-NAME>'

    # Create terraform resource group
    az group create --name $resourceGroupName --location $location

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

    $storageId=$(az storage account list --resource-group $resourceGroupName --output tsv --query "[?contains(name, '$($storageAccountName)')].id")
    $sp=$(az ad sp list --display-name $appName --query [0].id -o tsv)
    az role assignment create `
        --role "Storage Blob Data Contributor" `
        --assignee-object-id $sp `
        --assignee-principal-type ServicePrincipal `
        --scope $storageId


## Create your landing zone
This step consists in creating the landing zone containing all services already prepared to deploy application specific workload. In general, this step is provisioned by the administration team following enterprise governance, network and security.

For our demo, the landing zone looks like this, illustrated in the following schema.

![Architecture](Resources/Architecture-Landing%20Zone.png)

It consists of
- An enterprise private virtual network where two subnets are dedicated to the application workload
- Monitoring services for platform logs (Log Analytics Workspace) and application logs (Application Insights)
- A secret management service (Key Vault)
- An dedicated Azure Container App Environment to host all of our container images
- An Azure Front Door with an origin configured to target our Azure Container App Environment

This infrastructure is pre-provisioned through [code](IaC/landing-zone/) using Terraform. You can automate the deployment using the [GitHub Action](.github/workflows/landing-zone.yml).
More information on how to deploy this infrastructure is available [here](IaC/README.md).

## Self-hosted GitHub runner containers with Azure Container Apps
Because all of our landing zone services are not publicly available, we need to deploy a self-hosted GitHub runner inside of our private virtual network, giving GitHub access to all of our infrastructure and services.

A self-hosted Github runner might be deployed within a virtual machine or we can can create a container image (windows or linux) using docker that runs as container in any container service. In our case, we will take benefits of our pre-provisioned Azure Container App Environment to host the GitHub runner as an Azure Container App (ref. [Create a docker based self-hosted GitHub runner linux container](https://dev.to/pwd9000/create-a-docker-based-self-hosted-github-runner-linux-container-48dh)).

The first step is to build the self-hosted GitHub runner. The folder [docker-github-runner](docker-github-runner/) contains the docker image definition, and the image is built using a [GitHub action](.github/workflows/docker-github-runner.yml).

The next step is to create a GitHub Personal Access Token (PAT) to register the runner with. As a best practice, use only short lived PAT tokens and regenerate new tokens when a new version of a runner must be deployed. The minimum permission scopes required on the PAT token to register a self hosted runner are: "repo", "read:org". Store this access token as a secret of your repository within GitHub, enabling to use it in the deployment automation using GitHub actions.

Finally, you can deploy the self-hosted GitHub runner running the Terraform [scripts](IaC/docker-github-runner/). You can also automate the deployment using the [GitHub Action](.github/workflows/docker-github-runner-deploy.yml).

As the Azure Container App hosting the GitHub Runner uses auto-scaling rules based on Azure Storage Queue storage, your pipelines running on this runner must trigger a new container start. The [GitHub action](.github/workflows/keda-scale-test.yml) illustrates how this can be achieved using a first scale out job and scale in when job is terminated.

## Deploy the application hosting infrastructure
- Terraform pipeline
- Use KeyVault secrets to create ACA secrets
    End of march, public preview (https://github.com/microsoft/azure-container-apps/issues/608)
- Set ACA managed identity
- Grant access to Key Vault to ACA managed identity

## Deploy the application
- BFF
- WebApp
- WebApi