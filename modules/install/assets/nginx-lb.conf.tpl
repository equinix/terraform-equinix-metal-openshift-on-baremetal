stream {
    upstream backend_api {
        server ${bootstrap_ip}:6443;
${expanded_controlplane}
    }

    server {
        listen 6443;
        proxy_pass backend_api;
    }

    upstream backend_mcs {
        server ${bootstrap_ip}:22623;
${expanded_mcs}
    }

    server {
        listen 22623;
        proxy_pass backend_mcs;
    }

    upstream backend_https {
${expanded_compute_https}
    }

    server {
        listen 443;
        proxy_pass backend_https;
    }

    upstream backend_http {
${expanded_compute_http}
    }

    server {
        listen 80;
        proxy_pass backend_http;
    }

}

