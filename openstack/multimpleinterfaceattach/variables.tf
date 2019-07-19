variable "name" {}

variable "network_name" {}

variable "instance" {
  type = "list"
}
variable "quantity" {
  default = 1
}
variable "region" {
  default = "it-mil1"
}
