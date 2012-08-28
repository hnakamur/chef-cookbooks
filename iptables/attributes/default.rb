default.iptables.accept_lines = [
  "-A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT",
  "-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT",
  "-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT"
]
