# install_type: "server" or "client"
default.postgresql.install_type = "server"

# specify {major}.{minor} like 9.1, not like 9.1.5
default.postgresql.version = "9.1"

default.postgresql.repo_rpm_url = "http://yum.postgresql.org/9.1/redhat/rhel-6-x86_64/pgdg-centos91-9.1-4.noarch.rpm"

default.postgresql.auth_lines = [
  "host    all             all             192.168.11.0/24            md5"
]
