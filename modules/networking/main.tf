# =================================================================
# NETWORKING MODULE - MAIN CONFIGURATION
# =================================================================
# This module creates the virtual network, subnets, and network
# security groups to provide a secure network architecture
# =================================================================

# Create a virtual network to host all resources
resource "azurerm_virtual_network" "moodle_vnet" {
  name                = var.vnet_name
  address_space       = var.address_space  # CIDR block for the entire VNet
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# =================================================================
# SUBNET CONFIGURATION
# =================================================================
# Create multiple subnets to separate different tiers of the application
resource "azurerm_subnet" "subnets" {
  count                = length(var.subnet_names)
  name                 = var.subnet_names[count.index]
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.moodle_vnet.name
  address_prefixes     = [var.subnet_prefixes[count.index]]
  
  # For the database subnet (index 1), enable service endpoint for PostgreSQL
  # This allows secure communication between the VM and database
  service_endpoints    = count.index == 1 ? ["Microsoft.Sql"] : []
}

# =================================================================
# WEB TIER SECURITY
# =================================================================
# Create network security group for web subnet
resource "azurerm_network_security_group" "web_nsg" {
  name                = "web-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Allow HTTP traffic (port 80)
  security_rule {
    name                       = "allow-http"
    priority                   = 100         # Lower number means higher priority
    direction                  = "Inbound"   # Incoming traffic
    access                     = "Allow"     # Allow the traffic
    protocol                   = "Tcp"       # TCP protocol
    source_port_range          = "*"         # Any source port
    destination_port_range     = "80"        # HTTP port
    source_address_prefix      = "*"         # From any source
    destination_address_prefix = "*"         # To any destination
  }

  # Allow HTTPS traffic (port 443)
  security_rule {
    name                       = "allow-https"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"       # HTTPS port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow SSH for remote administration (port 22)
  security_rule {
    name                       = "allow-ssh"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"        # SSH port
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Associate NSG with web subnet
resource "azurerm_subnet_network_security_group_association" "web_nsg_association" {
  subnet_id                 = azurerm_subnet.subnets[0].id  # First subnet (web tier)
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

# =================================================================
# DATABASE TIER SECURITY
# =================================================================
# Create network security group for database subnet
resource "azurerm_network_security_group" "db_nsg" {
  name                = "db-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Allow PostgreSQL from web subnet only (port 5432)
  security_rule {
    name                       = "allow-postgres-from-web"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"             # PostgreSQL port
    source_address_prefix      = var.subnet_prefixes[0]  # Only from web subnet
    destination_address_prefix = "*"
  }

  # Deny all other inbound traffic for security
  security_rule {
    name                       = "deny-all-inbound"
    priority                   = 4096               # Lowest priority
    direction                  = "Inbound"
    access                     = "Deny"             # Deny the traffic
    protocol                   = "*"                # All protocols
    source_port_range          = "*"                # Any source port
    destination_port_range     = "*"                # Any destination port
    source_address_prefix      = "*"                # From any source
    destination_address_prefix = "*"                # To any destination
  }
}

# Associate NSG with database subnet
resource "azurerm_subnet_network_security_group_association" "db_nsg_association" {
  subnet_id                 = azurerm_subnet.subnets[1].id  # Second subnet (database tier)
  network_security_group_id = azurerm_network_security_group.db_nsg.id
}