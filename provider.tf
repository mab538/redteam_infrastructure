terraform {
    required_providers {
      digitalocean = {
          source = "digitalocean/digitalocean"
          version = "1.22.2"
      }
    }
}

# DIGITALOCEAN (Remote)
provider "digitalocean" {
    token = var.do_token
}

resource "digitalocean_ssh_key" "terraform" {
    name = "terraform"
    public_key = file("~/.ssh/id_rsa.pub")
}