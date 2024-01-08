terraform {
  required_version = ">= 0.13"
  #experiments = [module_variable_optional_attrs]

  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = "0.4.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}

provider "talos" {}


# resource "null_resource" "register_device" {

#   provisioner "local-exec" {
#     command = "/bin/bash scripts/install-boot-script.sh ${var.activation_key}"
#   }
# }