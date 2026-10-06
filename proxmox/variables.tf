variable "proxmox_endpoint" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type = string
  sensitive = true
  ephemeral = true
}
