resource "talos_machine_secrets" "machine_secrets" {}

data "talos_machine_configuration" "machineconfig_cp" {
  cluster_name     = var.cluster_name
  cluster_endpoint = var.cluster_endpoint
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
  machine_type     = "controlplane"
}

# resource "talos_machine_configuration_worker" "machineconfig_worker" {
#   cluster_name     = var.cluster_name
#   cluster_endpoint = var.cluster_endpoint
#   machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
# }

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  nodes            = [for k, v in var.node_data.controlplanes : k]
}

resource "talos_machine_configuration_apply" "cp_config_apply" {
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
  for_each                    = var.node_data.controlplanes
  endpoint                    = each.key
  node                        = each.key
  config_patches = [
    templatefile("${path.module}/templates/patch.yaml.tmpl", {
      hostname     = each.value.hostname == null ? format("%s-cp-%s", var.cluster_name, index(keys(var.node_data.controlplanes), each.key)) : each.value.hostname
      install_disk = each.value.install_disk
    }),
    file("${path.module}/files/cp-scheduling.yaml"),
  ]
}

# resource "talos_machine_configuration_apply" "worker_config_apply" {
#   talos_config          = talos_client_configuration.talosconfig.talos_config
#   machine_configuration = talos_machine_configuration_worker.machineconfig_worker.machine_config
#   for_each              = var.node_data.workers
#   endpoint              = each.key
#   node                  = each.key
#   config_patches = [
#     templatefile("${path.module}/templates/patch.yaml.tmpl", {
#       hostname     = each.value.hostname == null ? format("%s-cp-%s", var.cluster_name, index(keys(var.node_data.workers), each.key)) : each.value.hostname
#       install_disk = each.value.install_disk
#     })
#   ]
# }

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [
    talos_machine_configuration_apply.cp_config_apply
  ]
  node         = [for k, v in var.node_data.controlplanes : k][0]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
}

data "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on = [
    talos_machine_bootstrap.bootstrap
  ]
  node         = [for k, v in var.node_data.controlplanes : k][0]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
}

resource "local_file" "kubeconfig" {
    content  = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
    filename = "configs/kubeconfig"
}
