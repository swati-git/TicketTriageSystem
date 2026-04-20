resource "azurerm_log_analytics_workspace" "container_app_logs" {
  name                       = "container-app-logs-workspace-${var.region}-triage"
  location                   = azurerm_resource_group.multi-agent-systems.location
  resource_group_name        = azurerm_resource_group.multi-agent-systems.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
