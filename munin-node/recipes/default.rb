#
# Cookbook Name:: munin_node
# Recipe:: default
#
# Copyright 2012, Hiroaki Nakamura
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

enable_apache = node['munin-node'][:enable_apache]
enable_nginx = node['munin-node'][:enable_nginx]
enable_mysql = node['munin-node'][:enable_mysql]
apache_port = node[:apache][:port]
nginx_port = node[:nginx][:http_port]

group 'munin' do
  gid node[:munin][:gid]
end

user 'munin' do
  uid node[:munin][:uid]
  gid 'munin'
  shell '/sbin/nologin'
  comment 'Munin networked resource monitoring tool'
end

package "munin-node"

## memory_available plugin
cookbook_file '/usr/share/munin/plugins/memory_available' do
  source 'memory_available'
  owner 'root'
  group 'root'
  mode '0755'
end

## apache plugins

bash 'make_apache_plugins_links' do
  code <<-EOH
    ln -sf /usr/share/munin/plugins/apache_* /etc/munin/plugins/
  EOH
  only_if { enable_apache }
end
bash 'remove_apache_plugins_links' do
  code <<-EOH
    rm -f /etc/munin/plugins/apache_*
  EOH
  not_if { enable_apache }
end


## nginx plugins

cookbook_file '/etc/nginx/default.d/nginx_status.conf' do
  source 'nginx_status.conf'
  owner 'root'
  group 'root'
  mode '0644'
  only_if { enable_nginx }
end
bash 'reload_nginx_for_nginx_status' do
  code <<-EOH
    service nginx reload &&
    mkdir -p /root/.chef/munin_node/nginx_reloaded
  EOH
  only_if do
    enable_nginx &&
    !FileTest.exist?("/root/.chef/munin_node/nginx_reloaded")
  end
end
bash 'make_nginx_plugins_links' do
  code <<-EOH
    ln -sf /usr/share/munin/plugins/nginx_* /etc/munin/plugins/
  EOH
  only_if { enable_nginx }
end
bash 'remove_nginx_plugins_links' do
  code <<-EOH
    rm -f /etc/munin/plugins/nginx_*
  EOH
  not_if { enable_nginx }
end


## mysql plugins

cookbook_file '/usr/share/munin/plugins/mysql_connections' do
  source 'mysql_connections'
  owner 'root'
  group 'root'
  mode '0755'
  only_if { enable_mysql }
end

bash 'make_link_mysql_plugins' do
  code <<-EOH
    ln -sf /usr/share/munin/plugins/mysql_{bytes,connections,innodb,queries,slowqueries} /etc/munin/plugins/
  EOH
  only_if { enable_mysql }
end
bash 'remove_mysql_plugins_links' do
  code <<-EOH
    rm -f /etc/munin/plugins/mysql_*
  EOH
  not_if { enable_nginx }
end

bash 'create_munin_user_in_mysql' do
  code <<-EOH
    mysql -uroot <<'EOF'
create user munin;
grant usage on *.* to 'munin'@'localhost';
EOF
  EOH
  only_if do
    enable_mysql &&
    `echo "select count(*) from mysql.user where user = 'munin'" | mysql -uroot --skip-column-names`.chomp == '0'
  end
end

template '/etc/munin/plugin-conf.d/munin-node' do
  source 'munin-node.plugin.conf.erb'
  owner "root"
  group "root"
  mode '0644'
  variables(
    :apache_port => apache_port,
    :enable_apache => enable_apache,
    :nginx_port => nginx_port,
    :enable_nginx => enable_nginx,
    :enable_mysql => enable_mysql
  )
end

template '/etc/munin/munin-node.conf' do
  source 'munin-node.conf.erb'
  owner "root"
  group "root"
  mode '0644'
  variables(
    :cidr_configs => node['munin-node'][:cidr_configs]
  )
end

bash 'install_munin_node_plugins' do
  code <<-EOH
    perl /usr/sbin/munin-node-configure --shell --families=contrib,auto | sh -x
    rm -f /etc/munin/plugins/mysql_isam_space_information_schema || :
  EOH
end

service 'munin-node' do
  action [:enable, :start]
end
