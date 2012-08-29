default.munin.version = "2.0.4"
default.munin.gid = 403
default.munin.uid = 403

default.munin.enable_apache = true
default.munin.enable_mysql = true

default.munin_node.cidr_configs = [
  "cidr_allow 127.0.0.1/32"
]

default.apache.port = 8001

# open port 4949 in iptables if munin server is running on a remote machine.
# add the line below and uncomment it in iptables.accept_lines in node.json.
#
#  "-A INPUT -m state --state NEW -m tcp -p tcp --dport 4949 -j ACCEPT",
