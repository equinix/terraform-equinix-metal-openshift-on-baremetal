#!ipxe

set release ${ ocp_version }
set zstream ${ ocp_version_zstream }
set arch x86_64
set coreos-url http://54.173.18.88/pub/openshift-v4/dependencies/rhcos/$${release}/$${release}.$${zstream}
set coreos-img $${coreos-url}/rhcos-$${release}.$${zstream}-$${arch}-metal.$${arch}.raw.gz
set console console=ttyS1,115200n8
set first-boot coreos.first_boot=1
set auto-login coreos.autologin
set oem coreos.oem.id=packet
 
kernel $${coreos-url}/rhcos-$${release}.$${zstream}-$${arch}-installer-kernel-$${arch} $${console} $${first-boot} $${auto-login} ip=dhcp nomodeset rd.neednet=1 initrd=rhcos-$${release}.$${zstream}-$${arch}-installer-initramfs.$${arch}.img coreos.inst=yes coreos.inst.install_dev=sda coreos.inst.image_url=$${coreos-img} coreos.inst.ignition_url=http://${ bastion_ip }:8080/${ node_type }.ign
initrd $${coreos-url}/rhcos-$${release}.$${zstream}-$${arch}-installer-initramfs.$${arch}.img
boot
