variable "cores" {
  type    = number
  default = 4
}

variable "disk_size" {
  type    = string
  default = "50G"
}

variable "memory" {
  type    = number
  default = 10240
}

variable "nodes" {
  type    = number
  default = 3
}

variable "name_prefix" {
  type = string
}

variable "net_cidr_prefix" {
  type = string
}

variable "net_gateway_addr" {
  type = string
}

variable "net_starting_hostnum" {
  type = number
}

variable "net_vlan" {
  type = number
}

variable "iso" {
  type = string
}
