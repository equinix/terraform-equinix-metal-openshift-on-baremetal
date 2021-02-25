locals {
  basedomain = replace(var.cluster_basedomain, "${var.cluster_name}.", "")
}
data "linode_domain" "basedomain" {
  domain = local.basedomain
}

resource "linode_domain_record" "dns_a_cluster_api" {
  domain_id   = data.linode_domain.basedomain.id
  record_type = "A"
  name        = "api.${var.cluster_name}"
  target      = var.node_ips[count.index]
  count       = (var.node_type == "lb" ? length(var.node_ips) : 0)
}

resource "linode_domain_record" "dns_a_cluster_api_int" {
  domain_id   = data.linode_domain.basedomain.id
  record_type = "A"
  name        = "api-int.${var.cluster_name}"
  target      = var.node_ips[count.index]
  count       = (var.node_type == "lb" ? length(var.node_ips) : 0)
}

resource "linode_domain_record" "dns_a_cluster_wildcard_https" {
  domain_id   = data.linode_domain.basedomain.id
  record_type = "A"
  name        = "*.apps.${var.cluster_name}"
  target      = var.node_ips[count.index]
  count       = (var.node_type == "lb" ? length(var.node_ips) : 0)
}

resource "linode_domain_record" "dns_a_node" {
  domain_id   = data.linode_domain.basedomain.id
  record_type = "A"
  name        = "${var.node_type}-${count.index}.${var.cluster_name}"
  target      = var.node_ips[count.index]
  count       = length(var.node_ips)
}

resource "linode_domain_record" "dns_a_etcd" {
  domain_id   = data.linode_domain.basedomain.id
  record_type = "A"
  name        = "etcd-${count.index}.${var.cluster_name}"
  target      = var.node_ips[count.index]
  count       = (var.node_type == "master" ? length(var.node_ips) : 0)
}

resource "linode_domain_record" "dns_srv_etcd" {
  domain_id   = data.linode_domain.basedomain.id
  record_type = "SRV"
  service     = "etcd-server-ssl"
  protocol    = "tcp"
  priority    = 0
  weight      = 10
  port        = 2380

  target = "etcd-${count.index}.${var.cluster_name}.${local.basedomain}"
  count  = (var.node_type == "master" ? length(var.node_ips) : 0)
}

