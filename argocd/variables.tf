variable "kubeconfig_content" {
  description = "Content of the kubeconfig file from Talos cluster"
  type        = string
  sensitive = true
}

variable "tal_bootstrap_complete" {
  description = "Flag or timestamp indicating the completion of the Talos bootstrap process"
  type        = string
}