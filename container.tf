
resource "azurerm_container_registry" "triage_acr" {
  name                = "triageregistryeastus"
  resource_group_name = azurerm_resource_group.multi-agent-systems.name
  location            = azurerm_resource_group.multi-agent-systems.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_container_app_environment" "triage_container_env" {
  name                       = "container-app-environment-${var.region}-triage"
  location                   = azurerm_resource_group.multi-agent-systems.location
  resource_group_name        = azurerm_resource_group.multi-agent-systems.name
  infrastructure_subnet_id   = azurerm_subnet.triage_subnet.id  
  depends_on = [azurerm_resource_provider_registration.app] 
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.container_app_logs.id

}


# The Container App Job
resource "azurerm_container_app_job" "triage_container_app_job" {
  name                         = "container-app-job-${var.region}-triage"
  location                     = azurerm_resource_group.multi-agent-systems.location
  resource_group_name          = azurerm_resource_group.multi-agent-systems.name
  container_app_environment_id = azurerm_container_app_environment.triage_container_env.id
  depends_on = [azurerm_resource_provider_registration.app] 

  identity {
    type = "SystemAssigned"
  }

  replica_timeout_in_seconds = 300
  replica_retry_limit        = 1

  manual_trigger_config {
    parallelism              = 1
    replica_completion_count = 1
  }


  secret {
    name  = "acr-password"
    value = azurerm_container_registry.triage_acr.admin_password
  }

  # Step 2 — tell the job how to authenticate to ACR using the secret
  registry {
    server               = azurerm_container_registry.triage_acr.login_server
    username             = azurerm_container_registry.triage_acr.admin_username
    password_secret_name = "acr-password"   # must match secret name above exactly
  }

  template {
    container {
      name   = "test-runner"
      image  = "${azurerm_container_registry.triage_acr.login_server}/cognitive-tests:latest"
      cpu    = 0.5
      memory = "1Gi"

      env {
        name  = "AZURE_OPENAI_ENDPOINT"
        value = azurerm_cognitive_account.triage_account.endpoint
      }

      env {
        name  = "AZURE_OPENAI_DEPLOYMENT"
        value = azurerm_cognitive_deployment.triage_deployment.name
      }
    }
  }
}

resource "azurerm_role_assignment" "cognitive_user" {
  scope                = azurerm_cognitive_account.triage_account.id
  role_definition_name = "Cognitive Services OpenAI User"
  principal_id         = azurerm_container_app_job.triage_container_app_job.identity[0].principal_id
}

resource "azurerm_resource_provider_registration" "app" {
  name = "Microsoft.App"
}


