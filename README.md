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

## Create your landing zone
- VNet
- ACA
- Log Analytics Workspace
- Key Vault
- GitHub Runner

## Register your AAD applications 
- App registrations

## Configure GitHub secrets

## Deploy the infrastructure
