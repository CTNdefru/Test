resource "azurerm_resource_group" "craa-rg" {
  name     = "Fri-test-rg"
  location = "East Us"
  tags = {
    environment = "dev"
  }
}

resource "azurerm_virtual_network" "craa-vn" {
  name                = "craa-network"
  resource_group_name = azurerm_resource_group.craa-rg.name
  location            = azurerm_resource_group.craa-rg.location
  address_space       = ["10.123.0.0/16"]


  tags = {
    environment = "dev"
  }
}

resource "azurerm_subnet" "craa-subnet" {
  name                 = "craa-subnet"
  resource_group_name  = azurerm_resource_group.craa-rg.name
  virtual_network_name = azurerm_virtual_network.craa-vn.name
  address_prefixes     = ["10.123.1.0/24"]
}

resource "azurerm_network_security_group" "craa-sg" {
  name                = "craa-sg"
  location            = azurerm_resource_group.craa-rg.location
  resource_group_name = azurerm_resource_group.craa-rg.name

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_security_rule" "craa-dev-rule" {
  name                        = "craa-dev-rule"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.craa-rg.name
  network_security_group_name = azurerm_network_security_group.craa-sg.name
}

resource "azurerm_subnet_network_security_group_association" "craa-sga" {
  subnet_id                 = azurerm_subnet.craa-subnet.id
  network_security_group_id = azurerm_network_security_group.craa-sg.id
}

resource "azurerm_public_ip" "craa-ip" {
  name                = "craa-ip"
  resource_group_name = azurerm_resource_group.craa-rg.name
  location            = azurerm_resource_group.craa-rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "dev"
  }
}

resource "azurerm_network_interface" "craa-nic" {
  name                = "craa-nic"
  location            = azurerm_resource_group.craa-rg.location
  resource_group_name = azurerm_resource_group.craa-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.craa-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.craa-ip.id
  }

  tags = {
    environment = "dev"
  }
}

resource "azurerm_windows_virtual_machine" "craa-vm01" {
  name                  = "craa-vm"
  resource_group_name   = azurerm_resource_group.craa-rg.name
  location              = azurerm_resource_group.craa-rg.location
  size                  = "Standard_F2"
  admin_username        = "adminuser"
  admin_password        = "P@$$w0rd1234!"
  network_interface_ids = [azurerm_network_interface.craa-nic.id]

  #custom_data = filebase64("customdata.tpl")

  # admin_ssh_key {
  #   username   = "adminuser"
  #   public_key = file("~/.ssh/id_rsa.pub")
  # }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  #    provisioner "local-exec" {
  #        command = templatefile("${var.host_os}-ssh-script.tpl", {
  #            hostname = self.public_ip_address,
  #            user = "adminuser",
  #            identityfile = "~/.ssh/id_rsa"
  #        })
  #        interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  #    }

  tags = {
    environment = "dev"
  }
}

data "azurerm_public_ip" "craa-ip-data" {
  name                = azurerm_public_ip.craa-ip.name
  resource_group_name = azurerm_resource_group.craa-rg.name
}

output "public_ip_address" {
  value = "${azurerm_windows_virtual_machine.craa-vm01.name}: ${data.azurerm_public_ip.craa-ip-data.ip_address}"
}