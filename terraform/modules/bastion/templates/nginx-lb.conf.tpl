stream {
    upstream backend_api {
        server bootstrap-0.${cluster_name}.${cluster_basedomain}:6443;
        server master-0.${cluster_name}.${cluster_basedomain}:6443;
        server master-1.${cluster_name}.${cluster_basedomain}:6443;
        server master-2.${cluster_name}.${cluster_basedomain}:6443;
    }

    server {
        listen 6443;
        proxy_pass backend_api;
    }
}


stream {
    upstream backend_mcs {
        server bootstrap-0.${cluster_name}.${cluster_basedomain}:22623;
        server master-0.${cluster_name}.${cluster_basedomain}:22623;
        server master-1.${cluster_name}.${cluster_basedomain}:22623;
        server master-2.${cluster_name}.${cluster_basedomain}:22623;
    }

    server {
        listen 22623;
        proxy_pass backend_mcs;
    }
}

stream {
    upstream backend_https {
        server master-0.${cluster_name}.${cluster_basedomain}:443;
        server master-1.${cluster_name}.${cluster_basedomain}:443;
        server master-2.${cluster_name}.${cluster_basedomain}:443;
    }

    server {
        listen 443;
        proxy_pass backend_https;
    }
}
