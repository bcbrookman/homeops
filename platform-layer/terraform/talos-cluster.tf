# -------------------------------------------------------------------------------
# Talos Image Schematic Retrieval
# -------------------------------------------------------------------------------

locals {
  factory_url     = "https://factory.talos.dev"
  platform        = "nocloud"
  arch            = "amd64"
  version         = "v1.10.2"
  vm_schematic_id = talos_image_factory_schematic.vm.id
  vm_iso_url      = "${local.factory_url}/image/${local.vm_schematic_id}/${local.version}/${local.platform}-${local.arch}.iso"
  vm_iso_filename = "talos-${local.version}-${local.platform}-${local.arch}.iso"
}

data "talos_image_factory_extensions_versions" "vm" {
  talos_version = local.version
  filters = {
    names = [
      "siderolabs/iscsi-tools",
      "siderolabs/vm-guest-agent",
      "siderolabs/util-linux-tools"
    ]
  }
}

resource "talos_image_factory_schematic" "vm" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.vm.extensions_info.*.name
      }
    }
  })
}

# Output the ISO url(s) and filename(s) so they can be downloaded manually.
# Unfortunately, they cannot be downloaded automatically using the currently
# configured providers.

output "vm_iso_url" { value = local.vm_iso_url }
output "vm_iso_filename" { value = local.vm_iso_filename }
output "vm_schematic_id" { value = local.vm_schematic_id }

# -------------------------------------------------------------------------------
# Talos VM Provisioning
# -------------------------------------------------------------------------------

# NOTE: The ISO is only used on initial install; changing it will not upgrade
# Talos. Upgrades can be performed by deleting and recreating nodes
# individually, or using talosctl.

module "talos_vms" {
  source               = "./modules/talos-vms"
  name_prefix          = "talos-vm"
  net_cidr_prefix      = "192.168.20.0/24"
  net_gateway_addr     = "192.168.20.1"
  net_starting_hostnum = 151
  net_vlan             = 20
  disk_size            = "100G"
  iso                  = "nas:iso/${local.vm_iso_filename}"
}

# -------------------------------------------------------------------------------
# Talos Cluster Configuration
# -------------------------------------------------------------------------------

locals {
  cluster_name         = "homeops"
  cluster_endpoint_vip = "192.168.20.100"
  patches = {
    cluster = yamlencode({
      cluster = {
        allowSchedulingOnControlPlanes = true
      }
    })
    controlplane = yamlencode({
      machine = {
        network = {
          interfaces = [
            {
              vip = {
                ip = local.cluster_endpoint_vip
              }
              deviceSelector = {
                physical = true
              }
              dhcp = false
            }
          ]
        }
      }
    })
    worker = yamlencode({
      machine = {
        network = {
          interfaces = [
            {
              deviceSelector = {
                physical = true
              }
              dhcp = false
            }
          ]
        }
      }
    })
  }
}

module "talos_cluster" {
  depends_on = [module.talos_vms]
  source     = "./modules/talos-cluster"

  cluster_name         = local.cluster_name
  cluster_endpoint_vip = local.cluster_endpoint_vip

  nodes = [
    {
      ip   = "192.168.20.151"
      type = "controlplane"
      patches = [
        local.patches.cluster,
        local.patches.controlplane
      ]
    },
    {
      ip   = "192.168.20.152"
      type = "controlplane"
      patches = [
        local.patches.cluster,
        local.patches.controlplane
      ]
    },
    {
      ip   = "192.168.20.153"
      type = "controlplane"
      patches = [
        local.patches.cluster,
        local.patches.controlplane
      ]
    },
  ]
}

# -------------------------------------------------------------------------------
# Local Config File Exports
# -------------------------------------------------------------------------------

# The following resources can be used to export the kubeconfig and talosconfig
# files when running `terraform apply` locally. They should remain commented out
# normally, but can be uncommented temporarily when needed.

# resource "local_file" "outputs_gitignore" {
#   content         = "**/*"
#   filename        = ".outputs/.gitignore"
#   file_permission = "0644"
# }

# resource "local_sensitive_file" "kubeconfig" {
#   content         = module.talos_cluster.cluster_kubeconfig_raw
#   filename        = ".outputs/${local.cluster_name}_kubeconfig"
#   file_permission = "0600"
# }

# resource "local_sensitive_file" "talosconfig" {
#   content         = module.talos_cluster.client_configuration_talosconfig
#   filename        = ".outputs/${local.cluster_name}_talosconfig"
#   file_permission = "0600"
# }
