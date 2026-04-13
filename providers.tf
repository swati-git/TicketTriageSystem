terraform {
    required_providers {
        azurerm = {
        # Specify what version of the provider we are going to utilise
        source  = "hashicorp/azurerm"
        version  = "=4.68.0"
    }
    
  }
}


provider "azurerm" {
    features{}
}