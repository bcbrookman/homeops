output "cluster_kubeconfig_raw" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "client_configuration_talosconfig" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}
