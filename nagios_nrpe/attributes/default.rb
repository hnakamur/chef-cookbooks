default.nagios_nrpe = {
  version: "2.13",
  server_ip: "127.0.0.1",
  commands: [
    {
      name: "check_user",
      line: "/usr/local/nagios/libexec/check_user -w 5 -c 10"
    },
    {
      name: "check_load",
      line: "/usr/local/nagios/libexec/check_load -w 12,8,4 -c 24,20,16"
    },
    {
      name: "check_zombie_procs",
      line: "/usr/local/nagios/libexec/check_procs -w 5 -c 10 -s Z"
    },
    {
      name: "check_total_procs",
      line: "/usr/local/nagios/libexec/check_procs -w 150 -c 200"
    },
    {
      name: "check_disk",
      line: "/usr/local/nagios/libexec/check_disk -w 20% -c 10% -p /"
    },
    {
      name: "check_munin_node_proc",
      line: "/usr/local/nagios/libexec/check_procs -c 1: -C munin-node"
    },
    {
      name: "check_nginx_proc",
      line: "/usr/local/nagios/libexec/check_procs -c 1: -C nginx"
    },
    {
      name: "check_httpd_proc",
      line: "/usr/local/nagios/libexec/check_procs -c 1: -C httpd"
    }
  ]
}

# open port 5666 in iptables.
# add the line below and uncomment it in iptables.accept_lines in node.json.
#
#  "-A INPUT -m state --state NEW -m tcp -p tcp --dport 5666 -j ACCEPT",
