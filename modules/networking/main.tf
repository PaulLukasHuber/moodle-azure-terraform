resource "azurerm_virtual_network" "moodle_vnet" {
  name                = "${var.project_name}-vnet"
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    environment = var.environment
    project     = var.project_name
  }
}

resource "azurerm_subnet" "web_subnet" {
  name                 = "${var.project_name}-web-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.moodle_vnet.name
  address_prefixes     = [var.web_subnet_address_prefix]

  # This subnet delegation is required for App Service integration
  delegation {
    name = "app-service-delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "db_subnet" {
  name                 = "${var.project_name}-db-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.moodle_vnet.name
  address_prefixes     = [var.db_subnet_address_prefix]
  
  # This service endpoint allows the database to accept connections from this subnet only
  service_endpoints    = ["Microsoft.Sql"]
}

# Network Security Group for web subnet
resource "azurerm_network_security_group" "web_nsg" {
  name                = "${var.project_name}-web-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow HTTP traffic
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTPS traffic
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
    project     = var.project_name
  }
}

# Network Security Group for database subnet
resource "azurerm_network_security_group" "db_nsg" {
  name                = "${var.project_name}-db-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Allow MySQL traffic from web subnet only
  security_rule {
    name                       = "AllowMySQLFromWebSubnet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3306"
    source_address_prefix      = var.web_subnet_address_prefix
    destination_address_prefix = "*"
  }

  # Deny all other inbound traffic
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = var.environment
    project     = var.project_name
  }
}

# Associate NSG with web subnet
resource "azurerm_subnet_network_security_group_association" "web_nsg_association" {
  subnet_id                 = azurerm_subnet.web_subnet.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

# Associate NSG with database subnet
resource "azurerm_subnet_network_security_group_association" "db_nsg_association" {
  subnet_id                 = azurerm_subnet.db_subnet.id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}