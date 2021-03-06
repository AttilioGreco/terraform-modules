module "windows-istance" {
  source = "github.com/entercloudsuite/terraform-modules//openstack/instance?ref=2.7"
  name = "${var.name}"
  image = "${var.image}"
  quantity = "${var.quantity}"
  external = "${var.external}"
  region = "${var.region}"
  flavor = "${var.flavor}"
  network_name = "${var.network_name}"
  sec_group = "${var.sec_group}"
  keypair = "${var.keypair}"
  userdata = "${data.template_file.cloud-config.*.rendered}"
  tags = {
    "server_group" = "${var.name}"
  }
}

data "template_file" "cloud-config" {
  template = "${file("${path.module}/cloud-config.ps1")}"
  count = "${var.quantity}"
  vars {
    password = "${var.password}"
  }
}
