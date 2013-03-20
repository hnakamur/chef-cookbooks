default.nginx.http_port = 80
default.nginx.ssl_port = 443
default.nginx.ssl_server_name = "_"
default.nginx.crt_file = "/etc/pki/tls/certs/localhost.crt"
default.nginx.key_file = "/etc/pki/tls/private/localhost.key"
default.nginx.gid = 400
default.nginx.uid = 400
default.nginx.worker_processes = 4
default.nginx.worker_connections = 1024
default.nginx.http_configs = <<'EOS'
log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" '
                  '"$http_user_agent" "$http_x_forwarded_for" "$scheme"';

map $scheme $ssl {
  default off;
  https on;
}

access_log  /var/log/nginx/access.log  main;

sendfile        on;
#tcp_nopush     on;

keepalive_timeout  65;
server_tokens off;
gzip  on;

server_names_hash_bucket_size 64;

client_max_body_size    100m;
client_body_buffer_size 128k;

proxy_set_header        Host $host;
proxy_set_header        X-Forwared-For $proxy_add_x_forwarded_for;
proxy_set_header        X-Protocol $http_x_protocol;
proxy_buffers           32 4k;
proxy_send_timeout      20m;
proxy_read_timeout      20m;
EOS
default.nginx.basic_auth_user_id = "someone"
default.nginx.basic_auth_user_password = "_change_this_in_node_json_"
default.nginx.allowed_addresses = [
  {:ip => "192.168.11.0/24", :comment => "my lan"},
  {:ip => "127.0.0.0/24", :comment => "localhost"}
]
