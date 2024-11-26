resource "azurerm_container_group" "aci_nginx" {
  name                = "aci-nginx"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  ip_address_type = "Public"
  dns_name_label  = "nginx-devops-challenge-gabriel-ladeia"


  network_profile_id = azurerm_network_profile.network_profile.id

  container {
    name   = "nginx"
    image  = "nginx:1.27-alpine"
    cpu    = "0.5"
    memory = "0.5"

    ports {
      port = 80
    }

    commands = [
      "sh", "-c",
      "nginx -g 'daemon off;'"
    ]
  }
}

# Network Profile for ACI to connect to VNet
resource "azurerm_network_profile" "network_profile" {
  name                = "aci-network-profile"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  container_network_interface {
    name = "aci-nic"

    ip_configuration {
      name      = "ipconfig1"
      subnet_id = azurerm_subnet.subnet-aci.id
    }
  }
}
