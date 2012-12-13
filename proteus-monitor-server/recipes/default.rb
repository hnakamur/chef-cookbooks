#
# Cookbook Name:: proteus-monitor-server
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

install_dir = node['proteus-monitor-server']['install_dir']

git install_dir do
  repository "https://github.com/ameba-proteus/proteus-monitor-server.git"
  reference "master"
  action :sync
end

bash "install-proteus-monitor-server-node-modules" do
  cwd install_dir
  code <<-EOH
    npm install
  EOH
  creates "#{install_dir}/node_modules"
end

directory '/service/proteus-monitor-server' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/service/proteus-monitor-server/run' do
  source 'proteus-monitor-server-daemontools.sh.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables(
    :install_dir => install_dir
  )
end
