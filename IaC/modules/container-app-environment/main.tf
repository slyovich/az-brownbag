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