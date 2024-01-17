terraform {
  required_version = ">= 0.13"

  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.1.1"
    }
  }
}

provider "talos" {}

module "argo_module" {
  source   = "./argocd"

  kubeconfig_content = talos_cluster_kubeconfig.kubeconfig.kube_config
  tal_bootstrap_complete = talos_machine_bootstrap.bootstrap.id
}

module "local_storage" {
  source   = "./local_storage_provider"

  kubeconfig_content = talos_cluster_kubeconfig.kubeconfig.kube_config
  tal_bootstrap_complete = talos_machine_bootstrap.bootstrap.id
}
