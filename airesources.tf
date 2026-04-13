resource azurerm_resource_group "multi-agent-systems" {
    name = "rg-${var.region}-multi-agent-systems"
    location = var.region

}

resource "azurerm_cognitive_account" "triage-account" {
  name                = "triage-account"
  location            = azurerm_resource_group.multi-agent-systems.location
  resource_group_name = azurerm_resource_group.multi-agent-systems.name
  kind                = "AIServices"
  sku_name            = "S0"
  project_management_enabled = true

  identity {
    type = "SystemAssigned"
  }

  custom_subdomain_name =  "triage-system"

} 


resource "azurerm_cognitive_account_project" "triage-project" {
  name                 = "triage-project"
  cognitive_account_id = azurerm_cognitive_account.triage-account.id
  location             = azurerm_resource_group.multi-agent-systems.location
  description          = "A ticket-triage system "
  display_name         = "ticket-triage"

  identity {
    type = "SystemAssigned"
  }

}




