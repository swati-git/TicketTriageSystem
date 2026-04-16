resource "azurerm_virtual_network" "triage_vnet" {
  name                = "vnet-${var.region}-triage"
  resource_group_name = azurerm_resource_group.multi-agent-systems.name
  location            = azurerm_resource_group.multi-agent-systems.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "triage_subnet" {
  name                 = "subnet-${var.region}-triage"
  resource_group_name  = azurerm_resource_group.multi-agent-systems.name
  virtual_network_name = azurerm_virtual_network.triage_vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  service_endpoints = [
    "Microsoft.CognitiveServices", # OpenAI (embeddings + GPT-4o)
    "Microsoft.KeyVault"           # Key Vault (secrets)
  ]
}