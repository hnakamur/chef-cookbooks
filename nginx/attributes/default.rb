default.nginx = {
  version: "1.2.3",
  http_port: 81,
  https_port: 444,
  gid: 400,
  uid: 400,
  basic_auth_user_id: "someone",
  basic_auth_user_pass: "_change_this_in_node_json_",
  allowed_addresses: [
    {ip: "192.168.11.0/24", comment: "my lan"},
    {ip: "127.0.0.0/24", comment: "localhost"}
  ]
}

default.ssl_certificate = {
  subject: "/C=JP/ST=Kanagawa/L=Yokohama City/CN=test2.example.com",
  crt_file: "/etc/pki/tls/certs/test2.example.com.crt",
  key_file: "/etc/pki/tls/private/test2.example.com.key"
}
