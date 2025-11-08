# -------------------------------------------------------------------------------
# Talos Image Schematic Retrieval
# -------------------------------------------------------------------------------

locals {
  factory_domain        = "factory.talos.dev"
  factory_url           = "https://${local.factory_domain}"
  talos_install_version = "1.11.3"
  bm_platform           = "metal"
  bm_arch               = "amd64"
  bm_installer_image    = "${local.factory_domain}/${local.bm_platform}-installer/${local.bm_schematic_id}:v${local.talos_install_version}"
  bm_iso_filename       = "talos-v${local.talos_install_version}-${local.bm_platform}-${local.bm_arch}.iso"
  bm_iso_url            = "${local.factory_url}/image/${local.bm_schematic_id}/v${local.talos_install_version}/${local.bm_platform}-${local.bm_arch}.iso"
  bm_schematic_id       = talos_image_factory_schematic.bm.id
}

data "talos_image_factory_extensions_versions" "bm" {
  talos_version = local.talos_install_version
  filters = {
    names = [
      "siderolabs/i915",
      "siderolabs/intel-ice-firmware",
      "siderolabs/intel-ucode",
      "siderolabs/iscsi-tools",
      "siderolabs/util-linux-tools",
    ]
  }
}

resource "talos_image_factory_schematic" "bm" {
  schematic = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = data.talos_image_factory_extensions_versions.bm.extensions_info.*.name
      }
    }
  })
}

# Output the ISO url(s) and filename(s) so they can be downloaded manually.
# Unfortunately, they cannot be downloaded automatically using the currently
# configured providers.

output "bm_iso_url" { value = local.bm_iso_url }
output "bm_iso_filename" { value = local.bm_iso_filename }
output "bm_schematic_id" { value = local.bm_schematic_id }
output "bm_installer_image" { value = local.bm_installer_image }
output "bm_iso_download_cmd" { value = "wget -O ${local.bm_iso_filename} ${local.bm_iso_url}" }

# -------------------------------------------------------------------------------
# Talos Cluster Configuration
# -------------------------------------------------------------------------------

locals {
  cluster_name          = "talos3203"
  cluster_endpoint_vip  = "192.168.20.100"
  cluster_endpoint_port = "6443"

  kubernetes_version   = "1.34.0"
  talos_config_version = "1.10.2"

  cilium_cli_tag           = "v0.18.3"
  cilium_shared_ingress_ip = "192.168.20.231"

  common_net_prefix  = "/24"
  common_net_gateway = "192.168.20.1"

  nodes = [
    {
      ip   = "192.168.20.171"
      type = "controlplane"
    },
    {
      ip   = "192.168.20.172"
      type = "controlplane"
    },
    {
      ip   = "192.168.20.173"
      type = "controlplane"
    },
  ]

  cluster_patch = templatefile("templates/cluster.tftpl", {
    cilium_cli_tag           = local.cilium_cli_tag
    local_apiserver_port     = local.cluster_endpoint_port
    cilium_shared_ingress_ip = local.cilium_shared_ingress_ip
  })
}

module "talos_cluster" {
  source = "./modules/talos-cluster"

  cluster_name          = local.cluster_name
  cluster_endpoint_vip  = local.cluster_endpoint_vip
  cluster_endpoint_port = local.cluster_endpoint_port
  kubernetes_version    = local.kubernetes_version
  talos_version         = local.talos_config_version

  nodes = [
    merge(local.nodes[0], {
      patches = [
        local.cluster_patch,
        templatefile("templates/machine.tftpl", {
          cluster_endpoint_vip = local.cluster_endpoint_vip
          machine_type         = local.nodes[0].type
          hostname             = "${local.cluster_name}-bm01"
          install_disk         = "/dev/sdb"
          net_addr             = local.nodes[0].ip
          net_prefix           = local.common_net_prefix
          net_gateway          = local.common_net_gateway
          installer_image      = local.bm_installer_image
        })
      ]
    }),
    merge(local.nodes[1], {
      patches = [
        local.cluster_patch,
        templatefile("templates/machine.tftpl", {
          cluster_endpoint_vip = local.cluster_endpoint_vip
          machine_type         = local.nodes[1].type
          hostname             = "${local.cluster_name}-bm02"
          install_disk         = "/dev/sdb"
          net_addr             = local.nodes[1].ip
          net_prefix           = local.common_net_prefix
          net_gateway          = local.common_net_gateway
          installer_image      = local.bm_installer_image
        })
      ]
    }),
    merge(local.nodes[2], {
      patches = [
        local.cluster_patch,
        templatefile("templates/machine.tftpl", {
          cluster_endpoint_vip = local.cluster_endpoint_vip
          machine_type         = local.nodes[2].type
          hostname             = "${local.cluster_name}-bm03"
          install_disk         = "/dev/sdb"
          net_addr             = local.nodes[2].ip
          net_prefix           = local.common_net_prefix
          net_gateway          = local.common_net_gateway
          installer_image      = local.bm_installer_image
        })
      ]
    }),
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
