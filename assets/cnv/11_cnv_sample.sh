#!/bin/bash

# Use 'hostpath-provisioner' if you decide not to deploy OpenShift Container Storage
#storageclass="hostpath-provisioner"
#storageclass="ocs-storagecluster-cephfs"
storageclass="managed-nfs-storage"
ssh_pub=`cat ~/.ssh/id_rsa.pub`

## Install virtctl client on the bastion/LB

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@lb-0.${TF_VAR_cluster_name}.${TF_VAR_cluster_basedomain} 'wget https://github.com/kubevirt/kubevirt/releases/download/v0.46.1/virtctl-v0.46.1-linux-amd64 -O /usr/bin/virtctl ; chmod a+x /usr/bin/virtctl'

## Stage a Windows 2019 image from Vagrant on you bastion/LB

version=`curl -fsSL -L -H "Accept: application/json" https://app.vagrantup.com/peru/boxes/windows-server-2019-standard-x64-eval | jq -r '.versions[0].version'`

#ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ${TF_VAR_ssh_private_key_path} root@lb-0.${TF_VAR_cluster_name}.${TF_VAR_cluster_basedomain} << EOF
#    wget https://app.vagrantup.com/peru/boxes/windows-server-2016-standard-x64-eval/versions/${version}/providers/libvirt.box -O /usr/share/nginx/html/libvirt.box
#    cd /usr/share/nginx/html && tar xvzf libvirt.box
#    mv box.img W2K16.img
#    rm -f libvirt.box
#EOF

ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@lb-0.${TF_VAR_cluster_name}.${TF_VAR_cluster_basedomain} << EOF
    wget --no-check-certificate https://app.vagrantup.com/peru/boxes/windows-server-2019-standard-x64-eval/versions/${version}/providers/libvirt.box -O /usr/share/nginx/html/libvirt.box
    cd /usr/share/nginx/html && tar xvzf libvirt.box
    mv box.img W2K19.img
    rm -f libvirt.box
EOF

cat << EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: metal-example
spec: {}
---
apiVersion: kubevirt.io/v1alpha3
kind: VirtualMachine
metadata:
  annotations:
    kubevirt.io/latest-observed-api-version: v1alpha3
    kubevirt.io/storage-observed-api-version: v1alpha3
    name.os.template.kubevirt.io/win2k19: Microsoft Windows Server 2019
  name: eval19
  namespace: metal-example
  labels:
    app: eval19
    flavor.template.kubevirt.io/large: 'true'
    os.template.kubevirt.io/win2k19: 'true'
    workload.template.kubevirt.io/server: 'true'
spec:
  dataVolumeTemplates:
    - apiVersion: cdi.kubevirt.io/v1alpha1
      kind: DataVolume
      metadata:
        creationTimestamp: null
        name: eval19-rootdisk
      spec:
        pvc:
          accessModes:
            - ReadWriteMany
          resources:
            requests:
              storage: 55Gi
          storageClassName: ${storageclass}
          volumeMode: Filesystem
        source:
          http:
            url: 'http://lb-0.${TF_VAR_cluster_name}.${TF_VAR_cluster_basedomain}:8080/W2K19.img'
      status: {}
  running: true
  template:
    metadata:
      creationTimestamp: null
      labels:
        flavor.template.kubevirt.io/large: 'true'
        kubevirt.io/domain: eval19
        kubevirt.io/size: large
        os.template.kubevirt.io/win2k19: 'true'
        vm.kubevirt.io/name: eval19
        workload.template.kubevirt.io/server: 'true'
    spec:
      domain:
        clock:
          timer:
            hpet:
              present: false
            hyperv: {}
            pit:
              tickPolicy: delay
            rtc:
              tickPolicy: catchup
          utc: {}
        cpu:
          cores: 1
          sockets: 2
          threads: 1
        devices:
          disks:
            - bootOrder: 1
              disk:
                bus: virtio
              name: rootdisk
            - disk:
                bus: virtio
              name: cloudinitdisk
          interfaces:
            - masquerade: {}
              model: virtio
              name: nic0
        features:
          acpi: {}
          apic: {}
          hyperv:
            relaxed: {}
            spinlocks:
              spinlocks: 8191
            vapic: {}
        machine:
          type: pc-q35-rhel8.1.0
        resources:
          requests:
            memory: 8Gi
      evictionStrategy: LiveMigrate
      hostname: eval19
      networks:
        - name: nic0
          pod: {}
      terminationGracePeriodSeconds: 0
      volumes:
        - dataVolume:
            name: eval19-rootdisk
          name: rootdisk
        - cloudInitNoCloud:
            userData: |
              #cloud-config
              name: default
              ssh_authorized_keys:
                - >-
                  ${ssh_pub}
              hostname: eval19
          name: cloudinitdisk
EOF

# Expose your VM for RDP Access
# oc project metal-example
# virtctl expose vm eval19 --port=3389 --target-port=3389 --name=eval-rdp --type=NodePort

cat << EOF | oc apply -f -
apiVersion: kubevirt.io/v1alpha3
kind: VirtualMachine
metadata:
  annotations:
    kubevirt.io/latest-observed-api-version: v1alpha3
    kubevirt.io/storage-observed-api-version: v1alpha3
  name: eval-centos8
  namespace: metal-example
  labels:
    app: eval-centos8
    workload.template.kubevirt.io/server: 'true'
spec:
  dataVolumeTemplates:
    - apiVersion: cdi.kubevirt.io/v1alpha1
      kind: DataVolume
      metadata:
        creationTimestamp: null
        name: eval-centos8-rootdisk
      spec:
        pvc:
          accessModes:
            - ReadWriteMany
          resources:
            requests:
              storage: 15Gi
          storageClassName: ${storageclass}
          volumeMode: Filesystem
        source:
          http:
            url: 'https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.1.1911-20200113.3.x86_64.qcow2'
      status: {}
  running: true
  template:
    metadata:
      creationTimestamp: null
      labels:
        kubevirt.io/domain: eval-centos8
        vm.kubevirt.io/name: eval-centos8
        workload.template.kubevirt.io/server: 'true'
    spec:
      domain:
        clock:
          timer:
            hpet:
              present: false
            hyperv: {}
            pit:
              tickPolicy: delay
            rtc:
              tickPolicy: catchup
          utc: {}
        cpu:
          cores: 1
          sockets: 2
          threads: 1
        devices:
          disks:
            - bootOrder: 1
              disk:
                bus: virtio
              name: rootdisk
            - disk:
                bus: virtio
              name: cloudinitdisk
          interfaces:
            - masquerade: {}
              model: virtio
              name: nic0
        features:
          acpi: {}
          apic: {}
          hyperv:
            relaxed: {}
            spinlocks:
              spinlocks: 8191
            vapic: {}
        machine:
          type: pc-q35-rhel8.4.0
        resources:
          requests:
            memory: 2Gi
      evictionStrategy: LiveMigrate
      hostname: eval-centos8
      networks:
        - name: nic0
          pod: {}
      terminationGracePeriodSeconds: 0
      volumes:
        - dataVolume:
            name: eval-centos8-rootdisk
          name: rootdisk
        - cloudInitNoCloud:
            userData: |
              #cloud-config
              user: vagrant
              password: vagrant
              ssh_pwauth: True
              chpasswd:
                expire: false
              name: default
              ssh_authorized_keys:
                - >-
                  ${ssh_pub}
              hostname: eval-centos8
          name: cloudinitdisk
EOF

# virtctl expose vm eval-centos8 --port=22 --target-port=22 --name=eval-centos8 --type=NodePort
