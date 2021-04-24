terraform {
    required_providers {
      digitalocean = {
          source = "digitalocean/digitalocean"
          version = "1.22.2"
      }

      esxi = {
        source = "josenk/esxi"
      }
    }
}

# ESXi (Local)

provider "esxi" {
  alias = "esxi4"
  esxi_hostname = var.esxi4_hostname
  esxi_hostport = var.esxi4_hostport
  esxi_hostssl = var.esxi4_hostssl
  esxi_username = var.esxi4_username
  esxi_password = var.esxi4_password
}


# DIGITALOCEAN (Remote)
provider "digitalocean" {
    token = var.do_token
}

resource "digitalocean_ssh_key" "terraform" {
    name = "terraform"
    public_key = file("~/.ssh/id_rsa.pub")
}