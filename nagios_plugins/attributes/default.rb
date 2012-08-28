default.nagios_plugins.version = "1.4.16"

# This must not be written like below.
# If we do that, default.nagios.version becomes empty in other cookbooks.
#
# default.nagios = {
#   gid = 401,
#   uid = 401
# }
default.nagios.gid = 401
default.nagios.uid = 401
