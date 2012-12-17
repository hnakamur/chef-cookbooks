default.munin.gid = 403
default.munin.uid = 403
default.munin.web_interface_login = "munin"
default.munin.web_interface_password = "_set_password_in_node.json_"
default.munin.data_retention_period_in_days = 450
default.munin.host_tree_configs = [
  "[example.com;]",
  "[example.com;web1.example.com]",
  "    address 127.0.0.1",
  "    use_node_name yes"
]
