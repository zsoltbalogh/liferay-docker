auth_service:
    authentication:
        type: github
    cluster_name: __CLUSTER_NAME__
    enabled: "yes"
    listen_addr: 0.0.0.0:3025
    proxy_listener_mode: multiplex
proxy_service:
    acme: {}
    enabled: "yes"
    https_keypairs:
    - cert_file: /etc/letsencrypt/live/__GITHUB_REDIRECT_HOST__/fullchain.pem
      key_file: /etc/letsencrypt/live/__GITHUB_REDIRECT_HOST__/privkey.pem
    https_keypairs_reload_interval: 0s
ssh_service:
    commands:
    - name: hostname
      command: [hostname]
      period: 1m0s
    enabled: "yes"
teleport:
    ca_pin: ""
    data_dir: /var/lib/teleport
    diag_addr: ""
    log:
        format:
            output: text
        output: stderr
        severity: INFO
    nodename: __GITHUB_REDIRECT_HOST__
version: v3
