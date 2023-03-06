terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
    }
  }

  // https://servian.dev/terraform-optional-variables-and-attributes-using-null-and-optional-flag-62c5cd88f9ca
  experiments = [module_variable_optional_attrs]
}