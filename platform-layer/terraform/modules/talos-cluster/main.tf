terraform {
  required_providers {
    talos = {
      source = "siderolabs/talos"
    }
  }
}

# -------------------------------------------------------------------------------
# Client Configuration
# -------------------------------------------------------------------------------

locals {
  all_node_ips          = [for k, v in var.nodes : v.ip]
  worker_node_ips       = [for k, v in var.nodes : v.ip if v.type == "worker"]
  controlplane_node_ips = [for k, v in var.nodes : v.ip if v.type == "controlplane"]
}

resource "talos_machine_secrets" "this" {}

data "talos_client_configuration" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  cluster_name         = var.cluster_name
  endpoints            = local.controlplane_node_ips
  nodes                = local.all_node_ips
}

# -------------------------------------------------------------------------------
# Machine Configuration
# -------------------------------------------------------------------------------

data "talos_machine_configuration" "controlplane" {
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  machine_type       = "controlplane"
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.cluster_endpoint_vip}:${var.cluster_endpoint_port}"
  kubernetes_version = var.kubernetes_version
  talos_version      = var.talos_version
}

data "talos_machine_configuration" "worker" {
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  machine_type       = "worker"
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.cluster_endpoint_vip}:${var.cluster_endpoint_port}"
  kubernetes_version = var.kubernetes_version
  talos_version      = var.talos_version
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each = { for k, v in var.nodes : v.ip => v if v.type == "controlplane" }

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration

  node           = each.value.ip
  config_patches = each.value.patches
}

resource "talos_machine_configuration_apply" "worker" {
  for_each = { for k, v in var.nodes : v.ip => v if v.type == "worker" }

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration

  node           = each.value.ip
  config_patches = each.value.patches
}

# -------------------------------------------------------------------------------
# Cluster Bootstrap
# -------------------------------------------------------------------------------

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.controlplane[0]
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplane_node_ips[0]
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.controlplane_node_ips[0]
}
