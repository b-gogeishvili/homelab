terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  username = var.username
  password = var.password
  insecure = true
}
