resource "azurerm_subnet" "pe_subnet" {
  name                 = "pe-subnet"
  resource_group_name  = azurerm_resource_group.multi-agent-systems.name
  virtual_network_name = azurerm_virtual_network.triage_vnet.name
  address_prefixes     = ["10.0.4.0/24"]
  # no delegation needed for private endpoints
  # no service_endpoints needed for private endpoints
}


resource "azurerm_private_endpoint" "cognitive_pe" {
  name                = "cognitive-pe"
  location            = azurerm_resource_group.multi-agent-systems.location
  resource_group_name = azurerm_resource_group.multi-agent-systems.name
  subnet_id           = azurerm_subnet.pe_subnet.id

  private_service_connection {
    name                           = "cognitive-psc"
    private_connection_resource_id = azurerm_cognitive_account.triage_account.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }
}


resource "azurerm_private_dns_zone" "cognitive_dns" {
  name                = "privatelink.cognitiveservices.azure.com"
  resource_group_name = azurerm_resource_group.multi-agent-systems.name
}


resource "azurerm_private_dns_zone_virtual_network_link" "cognitive_dns_link" {
  name                  = "cognitive-dns-link"
  resource_group_name   = azurerm_resource_group.multi-agent-systems.name
  private_dns_zone_name = azurerm_private_dns_zone.cognitive_dns.name
  virtual_network_id    = azurerm_virtual_network.triage_vnet.id
  registration_enabled  = false
}

# 5. DNS A record pointing hostname to private endpoint IP
resource "azurerm_private_dns_a_record" "cognitive_dns_record" {
  name                = azurerm_cognitive_account.triage_account.custom_subdomain_name
  zone_name           = azurerm_private_dns_zone.cognitive_dns.name
  resource_group_name = azurerm_resource_group.multi-agent-systems.name
  ttl                 = 300
  records             = [
    azurerm_private_endpoint.cognitive_pe.private_service_connection[0].private_ip_address
  ]
}