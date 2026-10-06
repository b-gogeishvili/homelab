resource "proxmox_sdn_applier" "finalizer" {}

resource "proxmox_sdn_zone_simple" "example_zone_1" {
  id          = "zone1"
  mtu         = 1500
  dns         = "1.1.1.1"
  dns_zone    = "example.com"
  ipam        = "pve"
  reverse_dns = "1.1.1.1"

  depends_on = [
    proxmox_sdn_applier.finalizer
  ]
}
