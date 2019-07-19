variable "region" {}
variable "name" {}
variable "dns1" {
  default = "8.8.8.8"
}
variable "dns2" {
  default = "8.8.4.4"
}

variable "internal-network-cidr" {
    default = "10.2.0.0/16"
}

variable "internal-network-cidr-dhcp-start" {
    default = "10.2.0.2"
}

variable "internal-network-cidr-dhcp-end" {
    default = "10.2.254.255"
}

variable "no_gateway" {
    default = "true"  
}

variable "router_id" {
  default = ""
}

variable "router_name" {
  default = "router"
  
}

variable "host_routes" {
  type = "list"
  default = []
}
