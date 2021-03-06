variable "flavor" {
   default = "e3standard.x4"
}

variable "region" {}

variable "keyname" {}

variable "network_name" {}

variable "image" {}

variable "quantity" {
   default = 1
}

variable "tags" {
   default = {
    "server_group" = "ELASTICSEARCH"
  }
}
