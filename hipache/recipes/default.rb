#
# Cookbook Name:: hipache
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

package 'git'

bash 'install_hipache' do
  cwd '/var/www'
  code <<-EOH
    git clone https://github.com/dotcloud/hipache.git &&
    cd hipache &&
    . /usr/local/nvm/nvm.sh &&
    npm install forever http-proxy redis
  EOH
  not_if { FileTest.exists?("/var/www/hipache") }
end

bash 'add_forever_path_in_bashrc' do
  cwd '/'
  code <<-EOH
    cat >> ~/.bashrc <<'EOF'

export PATH=/var/www/hipache/node_modules/forever/bin:$PATH
EOF
  EOH
  not_if "grep -q '^export PATH=/var/www/hipache/node_modules/forever/bin:\$PATH$' /root/.bashrc"
end

template '/var/www/hipache/config.json' do
  source 'config.json.erb'
  variables(
    :crt_file => node[:ssl_certificate][:crt_file],
    :key_file => node[:ssl_certificate][:key_file]
  )
  not_if { FileTest.exists?("/root/.chef/hipache/config.json.written") }
end
directory "/root/.chef/hipache/config.json.written" do
  recursive true
end

cookbook_file '/etc/init.d/hipache' do
  source "init.hipache"
  owner 'root'
  group 'root'
  mode '0755'
  not_if { FileTest.exists?("/etc/init.d/hipache") }
end

service 'hipache' do
  action [:enable]
end
bash 'start_hipache' do
  cwd '/'
  code <<-EOH
    /etc/init.d/hipache start
  EOH
  not_if "/etc/init.d/hipache status | grep -q '/var/www/hipache/app.js'"
end
