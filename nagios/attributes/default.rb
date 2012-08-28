default.nagios.version = "3.4.1"
default.nagios.gid = 401
default.nagios.uid = 401
default.nagios.nagcmd_gid = 402
default.nagios.date_format = "iso8601"
default.nagios.localhost_ssh_notifications_enabled = 1
default.nagios.localhost_http_notifications_enabled = 1
default.nagios.generic_service = {
  max_check_attempts: 3,
  normal_check_interval: 10,
  retry_check_interval: 2
}
default.nagios.local_service = {
  max_check_attempts: 4,
  normal_check_interval: 5,
  retry_check_interval: 1
}
default.nagios.hostgroups = [
  {
    name: "app-servers",
    alias: "App Servers",
    members: "test2"
  }
]
default.nagios.hosts = [
  {
    name: "test2",
    alias: "test2.naru.net",
    address: "127.0.0.1"
  }
]
default.nagios.services = [
  {
    use: "generic-service",
    hostgroup_name: "app-servers",
    service_description: "PING",
    check_command: "check_ping!100.0,20%!500.0,60%",
    notifications_enabled: 1
  },
  {
    use: "generic-service",
    hostgroup_name: "app-servers",
    service_description: "DISK",
    check_command: "check_nrpe!check_disk",
    notifications_enabled: 1
  },
  {
    use: "generic-service",
    hostgroup_name: "app-servers",
    service_description: "Load Average",
    check_command: "check_nrpe!check_load",
    notifications_enabled: 1
  },
  {
    use: "generic-service",
    hostgroup_name: "app-servers",
    service_description: "SSH",
    check_command: "check_ssh",
    notifications_enabled: 1
  },
  {
    use: "generic-service",
    hostgroup_name: "web-servers",
    service_description: "HTTP",
    check_command: "check_http_url!/",
    notifications_enabled: 1
  },
  {
    use: "generic-service",
    hostgroup_name: "web-servers",
    service_description: "apache proc",
    check_command: "check_nrpe!check_httpd_proc",
    notifications_enabled: 1
  },
  {
    use: "generic-service",
    hostgroup_name: "web-servers",
    service_description: "nginx proc",
    check_command: "check_nrpe!check_nginx_proc",
    notifications_enabled: 1
  },
  {
    use: "generic-service",
    hostgroup_name: "app-servers",
    service_description: "munin-node proc",
    check_command: "check_nrpe!check_munin_node_proc",
    notifications_enabled: 1
  },
  {
    use: "generic-service",
    hostgroup_name: "app-servers",
    service_description: "mysqld proc",
    check_command: "check_nrpe!check_mysqld_proc",
    notifications_enabled: 1
  }
]
default.nagios.commands = [
  {
    name: "check_http_url",
    line: "$USER1$/check_http -H $HOSTADDRESS$ -u $ARG1$"
  }
]
default.nagios.web_interface_login =  "nagiosadmin"
default.nagios.web_interface_password =  "_change_this_in_node_json_"
