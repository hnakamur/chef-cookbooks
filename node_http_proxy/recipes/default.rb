#
# Cookbook Name:: node_http_proxy
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

directory "/var/www/node_http_proxy" do
  mode "0755"
  owner "root"
  group "root"
end

bash "install_node_http_proxy" do
  cwd "/var/www/node_http_proxy"
  code <<-EOH
    . /usr/local/nvm/nvm.sh &&
    npm install forever http-proxy
  EOH
end

template "/var/www/node_http_proxy/proxy.js" do
  source "proxy.js.erb"
  owner 'root'
  group 'root'
  mode 0644
  variables(
    :http_port => node[:node_http_proxy][:http_port],
    :https_port => node[:node_http_proxy][:https_port],
    :key_file => node[:ssl_certificate][:key_file],
    :crt_file => node[:ssl_certificate][:crt_file]
  )
  not_if { FileTest.exists?("/var/www/node_http_proxy/proxy.js") }
end

template "/var/www/node_http_proxy/router.json" do
  source "router.json.erb"
  owner 'root'
  group 'root'
  mode 0644
  variables(
    :virtual_hosts => node[:node_http_proxy][:virtual_hosts]
  )
  not_if { FileTest.exists?("/var/www/node_http_proxy/router.json") }
end

cookbook_file '/etc/init.d/node_http_proxy' do
  source "init.node_http_proxy"
  owner 'root'
  group 'root'
  mode '0755'
  not_if { FileTest.exists?("/etc/init.d/node_http_proxy") }
end

service 'node_http_proxy' do
  action [:enable]
end
bash 'start_node_http_proxy' do
  cwd '/'
  code <<-EOH
    /etc/init.d/node_http_proxy start
  EOH
  not_if "/etc/init.d/node_http_proxy status | grep -q '/var/www/node_http_proxy/proxy.js'"
end
