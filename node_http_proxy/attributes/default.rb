default.node_http_proxy.http_port = 80
default.node_http_proxy.https_port = 443
default.node_http_proxy.virtual_hosts = [
  {:name => "web1.example.com", :target => "127.0.0.1: =>62001"},
  {:name => "web2.example.com", :target => "127.0.0.1: =>62002"}
]
