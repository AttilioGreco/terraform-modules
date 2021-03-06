# Kubernetes join token 
resource "random_string" "kube-first-token-part" {
  length = 6
  upper = false
  special = false
}

resource "random_string" "kube-second-token-part" {
  length = 16
  upper = false
  special = false
}

# Cloud init scripts
data "template_file" "cloud-config-master" {
  template = "${file("${path.module}/kube-master.yml")}"
  count = "${var.master_count}"
  vars {
    name = "${var.master_name}"
    number = "${count.index}"
    hostname = "${var.master_name}-${count.index}"
    kube-token = "${format("%s.%s", random_string.kube-first-token-part.result, random_string.kube-second-token-part.result)}"
    pod-network-cidr = "${var.pod-network-cidr}"
    service-network-cidr = "${var.service-network-cidr}"
    dns-service-addr = "${cidrhost(var.service-network-cidr, 10)}"
    etcd = "${var.etcd}"
    master_count = "${var.master_count}"
    consul = "${var.consul}"
    consul_port = "${var.consul_port}"
    consul_datacenter = "${var.consul_datacenter}"
    consul_encrypt = "${var.consul_encrypt}"
    rancher_url = "${var.rancher_url}"
    rancher_cluster_token = "${var.rancher_cluster_token}"
  }
}

data "template_file" "cloud-config-worker" {
  template = "${file("${path.module}/kube-worker.yml")}"
  count = "${var.worker_count}"
  vars {
    name = "${var.worker_name}"
    kube-token = "${format("%s.%s", random_string.kube-first-token-part.result, random_string.kube-second-token-part.result)}"
    dns-service-addr = "${cidrhost(var.service-network-cidr, 10)}"
    consul = "${var.consul}"
    consul_port = "${var.consul_port}"
    consul_datacenter = "${var.consul_datacenter}"
    consul_encrypt = "${var.consul_encrypt}"
  }
}

# Kubernetes master node
module "kubernetes_master" {
  source = "github.com/mdacrema/terraform-modules//vcd/instance?ref=2.7"
  name = "${var.master_name}"
  template = "${var.template}"
  quantity = "${var.master_count}"
  cpus = "${var.master_cpus}"
  memory = "${var.master_memory}"
  discovery = "true"
  network_name = "${var.network_name}"
  keypair = "${var.keyname}"
  userdata = "${data.template_file.cloud-config-master.*.rendered}"
  vcd_username = "${var.vcd_username}"
  vcd_password = "${var.vcd_password}"
  vcd_org = "${var.vcd_org}"
  vcd_vdc = "${var.vcd_vdc}"
  vcd_url = "${var.vcd_url}"
  vcd_server = "${var.vcd_server}"
  catalog = "${var.catalog}"
}

# Kubernetes worker nodes
module "kubernetes_workers" {
  source = "github.com/mdacrema/terraform-modules//vcd/instance?ref=2.7"
  name = "${var.worker_name}"
  template = "${var.template}"
  quantity = "${var.worker_count}"
  cpus = "${var.worker_cpus}"
  memory = "${var.worker_memory}"
  discovery = "true"
  network_name = "${var.network_name}"
  keypair = "${var.keyname}"
  userdata = "${data.template_file.cloud-config-worker.*.rendered}"
  postdestroy = "${data.template_file.worker_cleanup.rendered}"
  vcd_username = "${var.vcd_username}"
  vcd_password = "${var.vcd_password}"
  vcd_org = "${var.vcd_org}"
  vcd_vdc = "${var.vcd_vdc}"
  vcd_url = "${var.vcd_url}"
  vcd_server = "${var.vcd_server}"
  catalog = "${var.catalog}"
}

data "template_file" "worker_cleanup" {
  template = "${file("${path.module}/cleanup.sh")}"
  vars {
    name = "${var.worker_name}"
    quantity = "${var.worker_count}"
    consul = "${var.consul}"
    consul_port = "${var.consul_port}"
    consul_datacenter = "${var.consul_datacenter}"
    consul_encrypt = "${var.consul_encrypt}"
  }
}

data "template_file" "master_cleanup" {
  template = "${file("${path.module}/cleanup.sh")}"
  vars {
    name = "${var.master_name}"
    quantity = "${var.master_count}"
    consul = "${var.consul}"
    consul_port = "${var.consul_port}"
    consul_datacenter = "${var.consul_datacenter}"
    consul_encrypt = "${var.consul_encrypt}"
  }
}
