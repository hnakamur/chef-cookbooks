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

version = node[:munin][:version]
enable_apache = node[:munin][:enable_apache]
enable_nginx = node[:munin][:enable_nginx]
enable_mysql = node[:munin][:enable_mysql]
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

%w{ make gcc }.each do |pkg|
  package pkg
end

bash 'munin_install_perl_modules' do
  code <<-EOH
    cpanm Net::Server Net::Server::Fork Time::HiRes Net::SNMP \
      Crypt::DES Digest::SHA1 Digest::HMAC Net::SSLeay Net::CIDR
  EOH
end

remote_file "/usr/local/src/munin-#{version}.tar.gz" do
  source "http://downloads.sourceforge.net/project/munin/stable/#{version}/munin-#{version}.tar.gz"
  case version
  when "2.0.4"
    checksum "309388e3528b41d727cea01233f0d4f60714e2de443576e1c472e8a1dc81722c"
  end
end

bash 'install_munin_node' do
  file_dir = "#{File.dirname(File.dirname(__FILE__))}/files/default"
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf munin-#{version}.tar.gz &&
    cd munin-#{version} &&
    if [ ! -f Makefile.config.orig ]; then
      patch -b -p1 < #{file_dir}/Makefile.config.patch
    fi &&
    make &&
    make install-common-prime install-node-prime install-plugins-prime &&
    chmod 777 /var/log/munin &&
    mkdir -p /usr/local/munin/www/docs &&
    chown munin:munin /usr/local/munin/www/docs
  EOH
  not_if { FileTest.exists?("/usr/local/munin/sbin/munin-node") }
end


## apache plugins

bash 'munin_install_perl_modules_for_apache_plugins' do
  code <<-EOH
    cpanm LWP::UserAgent
  EOH
  only_if { enable_apache }
end
bash 'make_apache_plugins_links' do
  code <<-EOH
    ln -sf /usr/local/munin/lib/plugins/apache_* /etc/munin/plugins/
  EOH
  only_if { enable_apache }
end
bash 'remove_apache_plugins_links' do
  code <<-EOH
    rm /etc/munin/plugins/apache_*
  EOH
  not_if { enable_apache }
end


## nginx plugins

cookbook_file '/etc/nginx/location.d/nginx_status.conf' do
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
  not_if { FileTest.exist?("/root/.chef/munin_node/nginx_reloaded") }
end
bash 'make_nginx_plugins_links' do
  code <<-EOH
    ln -sf /usr/local/munin/lib/plugins/nginx_* /etc/munin/plugins/
  EOH
  only_if { enable_nginx }
end
bash 'remove_nginx_plugins_links' do
  code <<-EOH
    rm /etc/munin/plugins/nginx_*
  EOH
  not_if { enable_nginx }
end


## mysql plugins

cookbook_file '/usr/local/munin/lib/plugins/mysql_connections' do
  source 'mysql_connections'
  owner 'root'
  group 'root'
  mode '0755'
  only_if { enable_mysql }
end

bash 'make_link_mysql_connections_plugin' do
  code <<-EOH
    ln -sf /usr/local/munin/lib/plugins/mysql_connections /etc/munin/plugins/
  EOH
  only_if do
    enable_mysql && 
    !FileTest.exists?("/etc/munin/plugins/mysql_connections")
  end
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
    :cidr_configs => node[:munin_node][:cidr_configs]
  )
end

bash 'install_munin_node_plugins' do
  code <<-EOH
    perl /usr/local/munin/sbin/munin-node-configure --shell --families=contrib,auto | sh -x
  EOH
end

template "/etc/init.d/munin-node" do
  source "munin-node.erb"
  owner 'root'
  group 'root'
  mode 0755
end

service 'munin-node' do
  action [:enable, :start]
end
