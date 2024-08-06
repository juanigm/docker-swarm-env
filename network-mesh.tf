# Create a Virtual Network Manager instance

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "network_manager_instance" {
  name                = "network-manager"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  scope_accesses      = ["Connectivity"]
  description         = "Mesh network topology"
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
}

# Create a network group

resource "azurerm_network_manager_network_group" "network_group" {
  name               = "network-group"
  network_manager_id = azurerm_network_manager.network_manager_instance.id
}

# Add virtual networks to a network group as dynamic members with Azure Policy

resource "random_pet" "network_group_policy_name" {
  prefix = "network-group-policy"
}

resource "azurerm_policy_definition" "network_group_policy" {
  name         = random_pet.network_group_policy_name.id
  policy_type  = "Custom"
  mode         = "Microsoft.Network.Data"
  display_name = "Policy Definition for Network Group"

  metadata = <<METADATA
    {
      "category": "Azure Virtual Network Manager"
    }
  METADATA

  policy_rule = <<POLICY_RULE
    {
      "if": {
        "allOf": [
          {
              "field": "type",
              "equals": "Microsoft.Network/virtualNetworks"
          },
          {
            "allOf": [
              {
              "field": "Name",
              "contains": "vnet"
              }
            ]
          }
        ]
      },
      "then": {
        "effect": "addToNetworkGroup",
        "details": {
          "networkGroupId": "${azurerm_network_manager_network_group.network_group.id}"
        }
      }
    }
  POLICY_RULE
}

resource "azurerm_subscription_policy_assignment" "azure_policy_assignment" {
  name                 = "${random_pet.network_group_policy_name.id}-policy-assignment"
  policy_definition_id = azurerm_policy_definition.network_group_policy.id
  subscription_id      = data.azurerm_subscription.current.id
}

# Create a connectivity configuration

resource "azurerm_network_manager_connectivity_configuration" "connectivity_config" {
  name                  = "connectivity-config"
  network_manager_id    = azurerm_network_manager.network_manager_instance.id
  connectivity_topology = "Mesh"
  global_mesh_enabled = true
  applies_to_group {
    group_connectivity = "DirectlyConnected"
    network_group_id   = azurerm_network_manager_network_group.network_group.id
  }
}


# Commit deployment

resource "azurerm_network_manager_deployment" "commit_deployment" {
  for_each = {for vnet in var.vnets: vnet.name => vnet}

  network_manager_id = azurerm_network_manager.network_manager_instance.id
  location           = each.value.region
  scope_access       = "Connectivity"
  configuration_ids  = [azurerm_network_manager_connectivity_configuration.connectivity_config.id]
}