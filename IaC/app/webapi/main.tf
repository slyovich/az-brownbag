terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    azapi = {
      source  = "azure/azapi"
    }
    mssql = {
      source  = "betr-io/mssql"
      version = "0.2.4"
    }
  }
  
  backend "azurerm" { }
}

provider "azurerm" {
  storage_use_azuread = true    # Allow access to storage with shared_access_key disabled
  features {}
}

provider "azapi" { }

provider "mssql" { }

locals {
  tags = {
    Application = "demo"
    Scope = "Application"
  }
  sql_dbconnection_string = "Server=${var.sqlDb.server-name}.database.windows.net; Authentication=Active Directory Default; Database=${var.sqlDb.name};MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;Persist Security Info=False;"
}

# Get current Resource group
data "azurerm_resource_group" "rg" {
  name     = var.resourceGroupName
}

# Get landing zone Resource group
data "azurerm_resource_group" "landing-zone" {
  name     = var.landingZone.resource-group-name
}

data "azapi_resource" "containerapp_environment" {
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  name      = var.containerAppEnvironment.name
  parent_id = data.azurerm_resource_group.landing-zone.id
  
  response_export_values  = ["id"]
}

module "webapi" {
  source = "../../modules/container-app"

  tags                           = local.tags
  location                       = var.location
  resourceGroupId                = data.azurerm_resource_group.rg.id

  container-app-environment-id   = jsondecode(data.azapi_resource.containerapp_environment.output).id

  container-app = {
    name = var.webApi.name
    image = var.image
    image-name = var.imageName
    tag = var.imageTag
    ingress = {
      external = false
      targetPort = 80
    }
    dapr = {
      enabled = true
      app_id = "webapi"
      app_port = 80
      app_protocol = "http"
    }
    cpu_requests = 0.75
    mem_requests = "1.5Gi"
    secrets = [ 
      {
          name = "gh-registry-token"
          value = var.githubRegistryToken
      },
      {
          name = "sql-connection-string"
          value = local.sql_dbconnection_string
      }
    ]
    env = [ 
      {
          name = "AzureAd__Domain"
          value = var.webApiAppConfig.domain
      },
      {
          name = "AzureAd__TenantId"
          value = var.webApiAppConfig.tenant-id
      },
      {
          name = "AzureAd__ClientId"
          value = var.webApiAppConfig.client-id
      },
      {
          name = "Sql__ConnectionString"
          secretRef = "sql-connection-string"
      }
    ]
    registry = {
      server = var.webApi.registry.server
      username = var.webApi.registry.username
      passwordSecretRef = "gh-registry-token"
    }
    scale = {
      minReplicas = 0
      maxReplicas = 3
      rules = [
        {
          name = "http-scaling"
          http = {
              metadata = {
                  concurrentRequests = 50
              }
          }
        }
      ]
    }
  }
}

data "azurerm_mssql_server" "app-server" {
  name                                 = var.sqlDb.server-name
  resource_group_name                  = data.azurerm_resource_group.rg.name
}

resource "mssql_user" "web" {
  server {
    host = data.azurerm_mssql_server.app-server.fully_qualified_domain_name
    login {
      username     = var.sqlDb.admin.username
      password     = var.sqlDbAdminPassword
    }
  }
  
  database  = var.sqlDb.name
  username  = var.webApi.name
  object_id = module.webapi.container-app-principal-id

  roles     = ["db_datareader", "db_datawriter"]
}