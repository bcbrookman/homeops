variable "cluster_name" {
  type = string
}

variable "cluster_endpoint_vip" {
  type = string
}

variable "cluster_endpoint_port" {
  type    = number
  default = 6443
}

variable "nodes" {
  type = list(object({
    ip      = string
    type    = string
    patches = list(string)
  }))
}
