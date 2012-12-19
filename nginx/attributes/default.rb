default.nginx.http_port = 81
default.nginx.start_server = true
default.nginx.gid = 400
default.nginx.uid = 400
default.nginx.worker_processes = 4
default.nginx.worker_connections = 1024
default.nginx.keepalive_timeout = 65
default.nginx.http_configs = <<'EOS'
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
default.nginx.default_server_configs = <<'EOS'
location / {
    root   /var/www/html/_default/htdocs;
    index  index.html index.htm;

    satisfy any;
    auth_basic_user_file /var/www/html/_default/.htpasswd;
    auth_basic "Authentication Required";
    include conf/allow_common_ip.conf;
    deny all;
}

#error_page  404              /404.html;

# redirect server error pages to the static page /50x.html
#
error_page   500 502 503 504  /50x.html;
location = /50x.html {
    root   /usr/share/nginx/html;
}
EOS
default.nginx.basic_auth_user_id = "someone"
default.nginx.basic_auth_user_password = "_change_this_in_node_json_"
default.nginx.allowed_addresses = [
  {:ip => "192.168.11.0/24", :comment => "my lan"},
  {:ip => "127.0.0.0/24", :comment => "localhost"}
]
