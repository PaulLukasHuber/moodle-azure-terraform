# Create a virtual network
resource "azurerm_virtual_network" "moodle_vnet" {
  name                = var.vnet_name
  address_space       = var.address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Create subnets
resource "azurerm_subnet" "subnets" {
  count                = length(var.subnet_names)
  name                 = var.subnet_names[count.index]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.moodle_vnet.name
  address_prefixes     = [var.subnet_prefixes[count.index]]
  
  # For the database subnet, enable service endpoint for PostgreSQL
  service_endpoints    = count.index == 1 ? ["Microsoft.Sql"] : []
}

# Create network security group for web subnet
resource "azurerm_network_security_group" "web_nsg" {
  name                = "web-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Allow HTTP
  security_rule {
    name                       = "allow-http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTPS
  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow SSH
  security_rule {
    name                       = "allow-ssh"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with web subnet
resource "azurerm_subnet_network_security_group_association" "web_nsg_association" {
  subnet_id                 = azurerm_subnet.subnets[0].id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

# Create network security group for database subnet
resource "azurerm_network_security_group" "db_nsg" {
  name                = "db-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Allow PostgreSQL from web subnet only
  security_rule {
    name                       = "allow-postgres-from-web"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = var.subnet_prefixes[0]
    destination_address_prefix = "*"
  }

  # Deny all other inbound traffic
  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with database subnet
resource "azurerm_subnet_network_security_group_association" "db_nsg_association" {
  subnet_id                 = azurerm_subnet.subnets[1].id
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}