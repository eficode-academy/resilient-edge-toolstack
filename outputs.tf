output "machineconfig_controlplane" {
  value     = data.talos_machine_configuration.machineconfig_cp.machine_configuration
  sensitive = true
}

# output "machineconfig_worker" {
#   value     = talos_machine_configuration_worker.machineconfig_worker.machine_config
#   sensitive = true
# }

output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}