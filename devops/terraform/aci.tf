resource "azurerm_public_ip" "aci_public_ip" {
  name                = "aci-nginx-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_container_group" "aci_nginx" {
  name                = "aci-nginx"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  ip_address_type = "Public"
  dns_name_label   = "nginx-devops-challenge"
  ports {
    port     = 80
    protocol = "TCP"
  }

  network_profile_id = azurerm_subnet.subnet.id

  container {
    name   = "nginx"
    image  = "nginx:1.27-alpine"
    cpu    = "0.5"
    memory = "0.5"

    ports {
      port = 80
    }

    environment_variables = {
      LETS_ENCRYPT_DOMAIN = "your-domain.com" #TODO domain
    }

    command = [
      "sh", "-c",
      "nginx -g 'daemon off;'"
    ]
  }
}
