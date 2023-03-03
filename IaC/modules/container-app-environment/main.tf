// https://thomasthornton.cloud/2022/09/05/deploying-azure-container-apps-into-your-virtual-network-using-terraform-and-azapi/
// https://github.com/thomast1906/thomasthorntoncloud-examples/tree/master/Container-Apps-AzAPI-Terraform
// https://stackoverflow.com/questions/73293980/terraform-failed-to-query-available-provider-packages-azapi

resource "azapi_resource" "containerapp_environment" {
  type      = "Microsoft.App/managedEnvironments@2022-03-01"
  name      = var.environment-name
  parent_id = var.resourceGroupId
  location  = var.location
  tags      = var.tags
 
  body = jsonencode({
    properties = {
      daprAIConnectionString = var.app-insights-connection-string,
      appLogsConfiguration = {
        destination = "log-analytics"
        logAnalyticsConfiguration = {
          customerId = var.log-analytics-workspace-id,
          sharedKey  = var.log-analytics-workspace-key
        }
      },
      vnetConfiguration = {
        internal = true,
        infrastructureSubnetId = var.subnet-id
      },
      zoneRedundant = true
    }
  })
  
  response_export_values  = ["id", "properties.defaultDomain", "properties.staticIp"]
  ignore_missing_property = true
}

resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = jsondecode(azapi_resource.containerapp_environment.output).properties.defaultDomain
  resource_group_name = var.resourceGroupName
  tags                = var.tags

  depends_on = [
    azapi_resource.containerapp_environment
  ]
}
 
resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  name                  = "containerapplink"
  resource_group_name   = var.resourceGroupName
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = var.vnet-id
}
 
resource "azurerm_private_dns_a_record" "containerapp_record" {
  name                = var.environment-name
  zone_name           = azurerm_private_dns_zone.private_dns_zone.name
  resource_group_name = var.resourceGroupName
  ttl                 = 300
  records             = ["${jsondecode(azapi_resource.containerapp_environment.output).properties.staticIp}"]
}

data "azurerm_lb" "internal" {
  name = "kubernetes-internal"
  resource_group_name = "MC_${split(".", jsondecode(azapi_resource.containerapp_environment.output).properties.defaultDomain)[0]}-rg_${split(".", jsondecode(azapi_resource.containerapp_environment.output).properties.defaultDomain)[0]}_${var.location}"

  depends_on = [
    azapi_resource.containerapp_environment
  ]
}

resource "azurerm_private_link_service" "container_app_environment" {
  name                                        = "pl${replace(var.environment-name, "-", "")}"
  resource_group_name                         = var.resourceGroupName
  location                                    = var.location
  tags                                        = var.tags

  load_balancer_frontend_ip_configuration_ids = [data.azurerm_lb.internal.frontend_ip_configuration.0.id]

  nat_ip_configuration {
    name                       = "snet-provider-default-1"
    subnet_id                  = var.private-link-subnet-id
    primary                    = true
    private_ip_address_version = "IPv4"
  }

  depends_on = [
    data.azurerm_lb.internal
  ]
}