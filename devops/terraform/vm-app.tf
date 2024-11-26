# Máquina Virtual Windows na subnet privada
resource "azurerm_windows_virtual_machine" "vm_windows" {
  name                  = "vm-windows-devops"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B2s"
  admin_username        = "usuarioadmin"
  admin_password        = "P@ssw0rd1234!" # Não se usa senha em código
  network_interface_ids = [azurerm_network_interface.nic_vm_private.id]

  os_disk {
    name                 = "osdisk-vm-windows"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  # Instalação do IIS e .NET
  provisioner "local-exec" {
    command = "powershell -Command Install-WindowsFeature -Name Web-Server; Invoke-WebRequest -Uri https://dotnet.microsoft.com/download/dotnet/thank-you/runtime-aspnetcore-6.0.0-windows-hosting-bundle-installer -OutFile C:\\install_dotnet.exe; Start-Process -FilePath C:\\install_dotnet.exe -ArgumentList '/quiet' -Wait"
  }
}

# Interface de Rede para a VM (associada à subnet privada)
resource "azurerm_network_interface" "nic_vm_private" {
  name                = "nic-vm-private"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
