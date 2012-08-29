default.munin.version = "2.0.4"
#
# 'cron' or 'cgi' ('cgi' includes FastCGI)
default.munin.generation_strategy = "cron"

default.munin.gid = 403
default.munin.uid = 403
default.munin.web_interface_login = "munin"
default.munin.web_interface_password = "_set_password_in_node.json_"
default.munin.host_tree_configs = [
  "[example.com;]",
  "[example.com;web1.example.com]",
  "    address 127.0.0.1",
  "    use_node_name yes"
]
