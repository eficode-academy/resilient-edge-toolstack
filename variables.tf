# variable "activation_key" {
#   description = "Activation key to register the device"
#   type        = string
# }

variable "cluster_name" {
  description = "A name to provide for the Talos cluster"
  type        = string
  default     = "edge"
}

variable "cluster_endpoint" {
  description = "The endpoint for the Talos cluster"
  type        = string
  default     = "https://192.168.1.109:6443"
}

variable "node_data" {
  description = "A map of node data"
  type = object({
    controlplanes = map(object({
      install_disk = string
      hostname     = optional(string)
    }))
    # workers = map(object({
    #   install_disk = string
    #   hostname     = optional(string)
    # }))
  })
  default = {
    controlplanes = {
      "192.168.1.109" = {
        install_disk = "/dev/sda"
      }
    }
    # workers = {
    #   "192.168.1.10" = {
    #     install_disk = "/dev/sda"
    #     hostname     = "worker-1"
    #   }
    # }
  }
}