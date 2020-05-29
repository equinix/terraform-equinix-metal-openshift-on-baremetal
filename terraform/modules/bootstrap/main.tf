variable "plan" {}
variable "node_count" {}
variable "facility" {}
variable "cluster_name" {}
variable "cluster_basedomain" {}
variable "ssh_private_key_path" {}
variable "project_id" {}
variable "cf_zone_id" {}
variable "bastion_ip" {}
variable "count_master" {}
variable "count_compute" {}
variable "depends" {
  type    = any
  default = null
}


resource "packet_device" "bootstrap" {
  depends_on         = [var.depends]
  hostname           = format("bootstrap-%01d.%s.%s", count.index, var.cluster_name, var.cluster_basedomain)
  operating_system   = "custom_ipxe"
  ipxe_script_url    = "http://${var.bastion_ip}:8080/bootstrap.ipxe"
  plan               = var.plan
  facilities         = [var.facility]
  count              = var.node_count
  billing_cycle    = "hourly"
  project_id       = var.project_id

  //user_data        = file("${path.root}/artifacts/bootstrap.ign")
}

resource "cloudflare_record" "dns_a_bootstrap" {
  zone_id    = var.cf_zone_id
  type       = "A"
  name       = "bootstrap-${count.index}.${var.cluster_name}.${var.cluster_basedomain}"
  value      = packet_device.bootstrap[count.index].access_public_ipv4
  count      = var.node_count
}

locals {
  expanded_masters = <<-EOT
        %{ for i in range(var.count_master) ~}
        server master-${i}.${var.cluster_name}.${var.cluster_basedomain}:6443;
        %{ endfor }
  EOT
  expanded_mcs = <<-EOT
        %{ for i in range(var.count_master) ~}
        server master-${i}.${var.cluster_name}.${var.cluster_basedomain}:22623;
        %{ endfor }
  EOT
  expanded_compute = <<-EOT
        %{ for i in range(var.count_compute) ~}
        server worker-${i}.${var.cluster_name}.${var.cluster_basedomain}:443;
        %{ endfor }
  EOT
}

/*
data "template_file" "nginx_lb" {
    template   = file("${path.module}/templates/nginx-lb.conf.tpl")

  vars = {
    cluster_name         = var.cluster_name
    cluster_basedomain   = var.cluster_basedomain
    count_master         = var.count_master
    count_compute        = var.count_compute
    expanded_masters     = local.expanded_masters
    expanded_compute     = local.expanded_compute
    expanded_mcs         = local.expanded_mcs
  }

}

resource "null_resource" "check_port" {

  depends_on = [ cloudflare_record.dns_a_bootstrap ]
  provisioner "local-exec" {
    command  = "while [[ $(curl -k -s -o /dev/null -w ''%%{http_code}'' https://${packet_device.bootstrap[count.index].access_public_ipv4}:6443) != '403' ]]; do sleep 2; done"
  }
  count      = var.node_count
}

resource "null_resource" "check_dir" {
  depends_on = [ cloudflare_record.dns_a_bootstrap, null_resource.check_port ]
  provisioner "remote-exec" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = var.bastion_ip
    } 


    inline = [
      "while [ ! -d /usr/share/nginx/html ]; do sleep 2; done; ls /usr/share/nginx/html/"
    ]
  }
}
/*
resource "null_resource" "reconfig_lb" {

  depends_on = [ null_resource.check_dir, var.depends ]

  provisioner "file" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = var.bastion_ip
    }

    content       = data.template_file.nginx_lb.rendered
    destination = "/usr/share/nginx/modules/nginx-lb.conf"
  }

  provisioner "remote-exec" {

    connection {
      private_key = file(var.ssh_private_key_path)
      host        = var.bastion_ip
    }


    inline = [
      "systemctl restart nginx"
    ]
  }
}
*/
output "finished" {
    depends_on = [null_resource.check_dir]
    value      = "Bootstrap node provisioning finished."
}

