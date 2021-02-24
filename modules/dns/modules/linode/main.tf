data "linode_domain" "basedomain" {
  domain = var.cluster_basedomain
}

resource "linode_domain_record" "dns_a_cluster_api" {
  domain_id   = linode_domain.basedomain[0].zone_id
  record_type = "A"
  name        = "api.${var.cluster_name}"
  target      = var.node_ips[count.index]
  count       = (var.node_type == "lb" ? length(var.node_ips) : 0)
}

resource "linode_domain_record" "dns_a_cluster_api_int" {
  domain_id   = linode_domain.basedomain[0].zone_id
  record_type = "A"
  name        = "api-int.${var.cluster_name}"
  target      = var.node_ips[count.index]
  count       = (var.node_type == "lb" ? length(var.node_ips) : 0)
}

resource "linode_domain_record" "dns_a_cluster_wildcard_https" {
  domain_id   = linode_domain.basedomain[0].zone_id
  record_type = "A"
  name        = "*.apps.${var.cluster_name}"
  target      = var.node_ips[count.index]
  count       = (var.node_type == "lb" ? length(var.node_ips) : 0)
}

resource "linode_domain_record" "dns_a_node" {
  domain_id   = linode_domain.basedomain[0].zone_id
  record_type = "A"
  name        = "${var.node_type}-${count.index}.${var.cluster_name}"
  target      = var.node_ips[count.index]
  count       = length(var.node_ips)
}

resource "linode_domain_record" "dns_a_etcd" {
  domain_id   = linode_domain.basedomain[0].zone_id
  record_type = "A"
  name        = "etcd-${count.index}.${var.cluster_name}"
  target      = var.node_ips[count.index]
  count       = (var.node_type == "master" ? length(var.node_ips) : 0)
}

resource "linode_domain_record" "dns_srv_etcd" {
  domain_id   = linode_domain.basedomain[0].zone_id
  record_type = "SRV"
  service     = "_etcd-server-ssl"
  protocol    = "_tcp"
  priority    = 0
  weight      = 10
  port        = 2380

  target = "etcd-${count.index}.${var.cluster_name}"
  count  = (var.node_type == "master" ? length(var.node_ips) : 0)
}

