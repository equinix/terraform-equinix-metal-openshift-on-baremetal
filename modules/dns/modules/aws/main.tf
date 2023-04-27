locals {
  basedomain = replace(var.cluster_basedomain, "${var.cluster_name}.", "")
}
data "aws_route53_zone" "basedomain" {
  name = local.basedomain
}

resource "aws_route53_record" "dns_a_cluster_api" {
  zone_id = data.aws_route53_zone.basedomain.id
  type    = "A"
  ttl     = 300
  name    = "api.${var.cluster_name}"
  records = var.node_ips
  count   = (var.node_type == "lb" ? 1 : 0)
}

resource "aws_route53_record" "dns_a_cluster_api_int" {
  zone_id = data.aws_route53_zone.basedomain.id
  type    = "A"
  ttl     = 300
  name    = "api-int.${var.cluster_name}"
  records = var.node_ips
  count   = (var.node_type == "lb" ? 1 : 0)
}

resource "aws_route53_record" "dns_a_cluster_wildcard_https" {
  zone_id = data.aws_route53_zone.basedomain.id
  type    = "A"
  ttl     = 300
  name    = "*.apps.${var.cluster_name}"
  records = var.node_ips
  count   = (var.node_type == "lb" ? 1 : 0)
}

resource "aws_route53_record" "dns_a_node" {
  zone_id = data.aws_route53_zone.basedomain.id
  type    = "A"
  ttl     = 300
  name    = "${var.node_type}-${count.index}.${var.cluster_name}"
  records = var.node_ips
  count   = length(var.node_ips)
}

resource "aws_route53_record" "dns_a_etcd" {
  zone_id = data.aws_route53_zone.basedomain.id
  type    = "A"
  ttl     = 300
  name    = "etcd-${count.index}.${var.cluster_name}"
  records = var.node_ips
  count   = (var.node_type == "master" ? length(var.node_ips) : 0)
}

resource "aws_route53_record" "dns_srv_etcd" {
  zone_id = data.aws_route53_zone.basedomain.id
  type    = "SRV"
  name    = "_etcd-server-ssl._tcp"

  records = [for i, addr in var.node_ips : "0 10 2380 ${addr}."]
  count   = (var.node_type == "master" ? length(var.node_ips) : 0)
}

