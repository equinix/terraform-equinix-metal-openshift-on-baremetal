{
   "ignition": {
      "config": {
        "merge": [
          {
            "source": "http://${ bastion_ip }:8080/${ node_type }.ign",
            "verification": {}
          }
        ]
    },
    "version": "3.2.0"
   },
   "storage": {
      "files": [
         { 
            "filesystem": "root",
            "path": "/etc/hosts",
            "mode": 644,
            "overwrite": true,
            "contents": {
               "source": "data:,127.0.0.1%20%20%20localhost%20localhost.localdomain%20localhost4%20localhost4.localdomain4%0A%3A%3A1%20%20%20%20%20%20%20%20%20localhost%20localhost.localdomain%20localhost6%20localhost6.localdomain6%0A%0A${bastion_ip}%20%20%20api.${cluster_name}.${cluster_basedomain}%0A${bastion_ip}%20%20%20api-int.${cluster_name}.${cluster_basedomain}%0A%0A"
            }
         },
         { 
            "filesystem": "root",
            "path": "/etc/chrony.conf",
            "mode": 420,
            "overwrite": true,
            "contents": {
               "source": "data:,pool%20pool.ntp.org%20iburst%0Adriftfile%20%2Fvar%2Flib%2Fchrony%2Fdrift%0Amakestep%201%20-1%0Artcsync%0Alogdir%20%2Fvar%2Flog%2Fchrony%0A%0A"
            }
         }
      ]
   },
  "passwd":{}
}