terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.11.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "25505c85-b04f-4d77-8c2a-0e3e507080a1"
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-devops-desafio"
  location = "eastus"
}

# VNet e Subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-devops"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-app"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet-aci" {
  name                 = "subnet-aci"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group (NSG)
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-devops"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-nginx-to-vm"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "10.0.2.0/24" # Subnet do ACI
    destination_address_prefix = "*"
    destination_port_range     = "80"
  }
  security_rule {
    name                       = "allow-winrm-to-vm"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "10.0.0.0/16" # Verificar se o Azure DevOps pode executar o Playbook Ansible com essa regra
    destination_address_prefix = "*"
    destination_port_range     = "5986"
  }
}


resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
