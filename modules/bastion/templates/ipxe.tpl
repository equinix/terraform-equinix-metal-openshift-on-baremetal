#!ipxe

set release ${ ocp_version }
set zstream ${ ocp_version_zstream }
set arch x86_64
set coreos-url http://${ bastion_ip }:8080
set coreos-img $${coreos-url}/rhcos-$${release}.$${zstream}-$${arch}-metal.$${arch}.raw.gz
set console console=ttyS1,115200n8
 
kernel $${coreos-url}/rhcos-$${release}.$${zstream}-$${arch}-installer-kernel-$${arch} $${console} ip=dhcp nameserver=1.1.1.1 nomodeset rd.peerdns=0 rd.neednet=1 initrd=rhcos-$${release}.$${zstream}-$${arch}-installer-initramfs.$${arch}.img coreos.inst=yes coreos.inst.install_dev=sda coreos.inst.image_url=$${coreos-img} coreos.inst.ignition_url=http://${ bastion_ip }:8080/${ node_type }-append.ign
initrd $${coreos-url}/rhcos-$${release}.$${zstream}-$${arch}-installer-initramfs.$${arch}.img
boot
