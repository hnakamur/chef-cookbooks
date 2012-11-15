default.nginx.http_port = 81
default.nginx.gid = 400
default.nginx.uid = 400
default.nginx.basic_auth_user_id = "someone"
default.nginx.basic_auth_user_pass = "_change_this_in_node_json_"
default.nginx.allowed_addresses = [
  {:ip => "192.168.11.0/24", :comment => "my lan"},
  {:ip => "127.0.0.0/24", :comment => "localhost"}
]

default.ssl_certificate.subject = "/C=JP/ST=Kanagawa/L=Yokohama City/CN=test2.example.com"
default.ssl_certificate.crt_file = "/etc/pki/tls/certs/test2.example.com.crt"
default.ssl_certificate.key_file = "/etc/pki/tls/private/test2.example.com.key"
