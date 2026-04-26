resource "azurerm_cognitive_account" "triage_account" {
  name                = "cognitive-account-${var.region}-triage"
  location            = azurerm_resource_group.multi-agent-systems.location
  resource_group_name = azurerm_resource_group.multi-agent-systems.name
  kind                = "AIServices"
  sku_name            = "S0"
  project_management_enabled = true
  
  identity {
    type = "SystemAssigned"
  }

  custom_subdomain_name =  "ticket-triage-system"

  public_network_access_enabled = false
  rai_policy_name      = azurerm_cognitive_account_rai_policy.ai_safety.name

  
} 

resource "azurerm_cognitive_account_project" "triage_project" {
  name                 = "cognitive-project-${var.region}-triage"
  cognitive_account_id = azurerm_cognitive_account.triage_account.id
  location             = azurerm_resource_group.multi-agent-systems.location
  description          = "A ticket-triage system "
  display_name         = "ticket-triage"

  identity {
    type = "SystemAssigned"
  }

}

resource "azurerm_cognitive_deployment" "triage_deployment" {
  name                 = "cognitive-deployment-${var.region}-triage"
  cognitive_account_id = azurerm_cognitive_account.triage_account.id

  model {
    format  = "OpenAI"
    name = "gpt-4o-mini"
    version = "2024-07-18"
  }

  sku {
    name = "GlobalStandard"
    capacity = 30
  }
}


