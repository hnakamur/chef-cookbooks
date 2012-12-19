#
# Cookbook Name:: nginx
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

hostname = `hostname`.chomp

group "nginx" do
  gid node[:nginx][:gid]
end

user "nginx" do
  uid node[:nginx][:uid]
  gid "nginx"
  home "/var/lib/nginx"
  shell "/bin/nologin"
  comment "Nginx web server"
end

cookbook_file "/etc/yum.repos.d/nginx.repo" do
  source "nginx.repo"
  owner "root"
  group "root"
  mode "0644"
end

yum_package "nginx" do
  action :install
  flush_cache [ :before ]
end

yum_package "httpd-tools"

directory "/var/log/old/nginx" do
  mode "0755"
  owner "nginx"
  group "nginx"
  recursive true
end

template "/etc/logrotate.d/nginx" do
  source "logrotate-nginx.erb"
  mode "0644"
  owner "root"
  group "root"
end

%w{ client_temp fastcgi_temp proxy_temp scgi_temp uwsgi_temp }.each do |dir|
  directory "/var/cache/nginx/#{dir}" do
    owner "nginx"
    group "root"
    mode "0700"
    recursive true
  end
end

directory "/etc/nginx/conf.d" do
  mode "0755"
  owner "root"
  group "root"
  recursive true
end

directory "/etc/nginx/conf" do
  mode "0755"
  owner "root"
  group "root"
  recursive true
end

template "/etc/nginx/nginx.conf" do
  source "nginx.conf.erb"
  variables(
    :worker_processes => node[:nginx][:worker_processes],
    :worker_connections => node[:nginx][:worker_connections],
    :keepalive_timeout => node[:nginx][:keepalive_timeout],
    :http_configs => node[:nginx][:http_configs]
  )
  not_if { FileTest.exists?("/root/.chef/nginx/nginx.conf.written") }
end
directory "/root/.chef/nginx/nginx.conf.written" do
  recursive true
end

template "/etc/nginx/conf.d/default.conf" do
  source "nginx.default.conf.erb"
  variables(
    :http_port => node[:nginx][:http_port],
    :default_server_configs => node[:nginx][:default_server_configs]
  )
  not_if { FileTest.exists?("/root/.chef/nginx/nginx.default.conf.written") }
end
directory "/root/.chef/nginx/nginx.default.conf.written" do
  recursive true
end

bash "create_htpasswd" do
  code <<-EOH
    mkdir -p /var/www/html/_default &&
    htpasswd -b -c /var/www/html/_default/.htpasswd \
      "#{node[:nginx][:basic_auth_user_id]}" \
      "#{node[:nginx][:basic_auth_user_password]}"
  EOH
  creates "/var/www/html/_default/.htpasswd"
end

template "/etc/nginx/conf/allow_common_ip.conf" do
  source "allow_common_ip.conf.erb"
  variables(
    :allowed_addresses => node[:nginx][:allowed_addresses]
  )
  not_if { FileTest.exists?("/etc/nginx/conf/allow_common_ip.conf") }
end

directory "/var/www/html/_default/htdocs" do
  owner "nginx"
  group "nginx"
  mode "0775"
  recursive true
end

template "/var/www/html/_default/htdocs/index.html" do
  source "index.html.erb"
  owner "nginx"
  group "nginx"
  mode "0644"
  variables(
    :hostname => hostname
  )
  not_if { FileTest.exists?("/var/www/html/_default/htdocs/index.html") }
end

service "nginx" do
  supports :restart => true, :reload => true
  action (node.nginx.start_server ? [:enable, :start] : [:enable])
end
