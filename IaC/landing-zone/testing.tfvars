resourceGroupName = "ARG-DEMO-BROWNBAG-CHN-02"

vnet = {
    name = "vnet-demo-brownbag-01"
    address_space = ["10.0.0.0/16"]
}

nsg = {
    "app" = {
      name = "nsg-demo-brownbag-01"
      rules = {
        "http" = {
            name                       = "AllowTagHTTPInbound"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "80"
            source_address_prefix      = "AzureFrontDoor.Backend"
            destination_address_prefix = "10.0.2.0/24"
        },
        "https" = {
            name                       = "AllowTagHTTPSInbound"
            priority                   = 200
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "443"
            source_address_prefix      = "AzureFrontDoor.Backend"
            destination_address_prefix = "10.0.2.0/24"
        }
      }
    },
    "privateEndpoint" = {
      name = "nsg-demo-brownbag-02"
      rules = {}
    }
}

subnets = {
    "app" = {
        nsg_name                                        = "nsg-demo-brownbag-01"
        name                                            = "app-subnet"
        address_space                                   = ["10.0.0.0/23"]
        private_endpoint_network_policies_enabled       = false
        private_link_service_network_policies_enabled   = false
        service_endpoints                               = []
    },
    "privateEndpoint" = {
        nsg_name                                        = "nsg-demo-brownbag-02"
        name                                            = "private-endpoint-subnet"
        address_space                                   = ["10.0.2.0/24"]
        private_endpoint_network_policies_enabled       = true
        private_link_service_network_policies_enabled   = false
        service_endpoints                               = []
    }
}

dns = {
    "sql" = "privatelink.database.windows.net",
    "keyvault" = "privatelink.vaultcore.azure.net"
    "redis" = "privatelink.redis.cache.windows.net"
}

workspaceName = "logs-demo-brownbag-01"
appInsightName = "aai-demo-brownbag-01"

keyVault = {
    name = "kv-demo-brownbag-01"
    subnet-key = "privateEndpoint"
    dns-key = "keyvault"
}

containerAppEnvironment = {
    name                    = "appenv-demo-brownbag-01"
    subnet-key              = "app"
    private-link-subnet-key = "privateEndpoint"
}

frontDoor = {
    name               = "fd-demo-brownbag-01"
    custom-domain-name = null
    endpoint-name      = "www"
}