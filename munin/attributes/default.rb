default.munin.nginx_munin_conf_dir = "/etc/nginx/ssl.d"
default.munin.web_interface_login = "munin"
default.munin.web_interface_password = "_set_password_in_node.json_"

default.munin.crontab_minute_field = "*/1"

# update_rate must be specified by seconds. ex) 60 -> OK, 1m -> NG.
default.munin.update_rate = "60"

# you can use human-readable format for graph_data_size.
# http://munin-monitoring.org/wiki/format-graph_data_size
default.munin.graph_data_size = "custom 400d"

default.munin.host_tree_configs = <<'EOS'
[example.com;]
[example.com;web1.example.com]
    address 127.0.0.1
    use_node_name yes
EOS
