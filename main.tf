data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

module "ssh-key" {
  source         = "./modules/ssh-key"
  public_ssh_key = var.public_ssh_key == "" ? "" : var.public_ssh_key
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.prefix}-aks"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  dns_prefix          = var.prefix
  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      # remove any new lines using the replace interpolation function
      key_data = replace(var.public_ssh_key == "" ? module.ssh-key.public_ssh_key : var.public_ssh_key, "\n", "")
    }
  }

  default_node_pool {
    name            = "nodepool"
    node_count           = var.agents_count
    vm_size         = var.agents_size
#    os_type         = "Linux"
    os_disk_size_gb = 50
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  tags = var.tags
}
