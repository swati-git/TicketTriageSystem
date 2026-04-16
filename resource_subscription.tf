resource azurerm_resource_group "multi-agent-systems" {
    name = "rg-${var.region}-multi-agent-systems"
    location = var.region

}
