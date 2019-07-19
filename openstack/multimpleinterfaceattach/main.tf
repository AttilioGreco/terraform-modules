data "openstack_networking_network_v2" "instance_network" {
  region = "${var.region}"
  name = "${var.network_name}"
}

resource "openstack_networking_port_v2" "ports" {
  count          = "${var.quantity}"
  name           = "${format("port-%02d", count.index + 1)}"
  network_id     = "${data.openstack_networking_network_v2.instance_network.id}"
  admin_state_up = "true"
}

resource "openstack_compute_interface_attach_v2" "ai_2" {
  instance_id = "${openstack_compute_instance_v2.instance_1.id}"
  port_id     = "${openstack_networking_port_v2.ports.*.id[count.index]}"
}


