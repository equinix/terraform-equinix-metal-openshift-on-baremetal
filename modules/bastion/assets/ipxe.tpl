#!ipxe

set release ${ ocp_version }
set zstream ${ ocp_version_zstream }
set arch x86_64
set coreos-url http://${ bastion_ip }:8080
set coreos-img $${coreos-url}/rhcos-$${release}.$${zstream}-$${arch}-live-rootfs.$${arch}.img
set console console=ttyS1,115200n8
 
kernel $${coreos-url}/rhcos-$${release}.$${zstream}-$${arch}-live-kernel-$${arch} initrd=main coreos.live.rootfs_url=$${coreos-img} coreos.inst.ignition_url=http://${ bastion_ip }:8080/${ node_type }-append.ign random.trust_cpu=on rd.luks.options=discard console=tty1 console=ttyS1,115200n8 coreos.inst.persistent-kargs="console=tty1 console=ttyS1,115200n8" coreos.inst.install_dev=/dev/sda
initrd --name main $${coreos-url}/rhcos-$${release}.$${zstream}-$${arch}-live-initramfs.$${arch}.img
boot
