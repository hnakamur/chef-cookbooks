#
# Cookbook Name:: proteus-monitor-agent
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

install_dir = node['proteus-monitor-agent']['install_dir']

git install_dir do
  repository "https://github.com/ameba-proteus/proteus-monitor-agent.git"
  reference "master"
  action :sync
end

bash "install-proteus-monitor-agent-node-modules" do
  cwd install_dir
  code <<-EOH
    npm install
  EOH
  creates "#{install_dir}/node_modules"
end

template "#{install_dir}/etc/agent.conf" do
  source 'agent.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :host => node['proteus-monitor-agent']['host'],
    :group => node['proteus-monitor-agent']['group'],
    :plugins => node['proteus-monitor-agent']['plugins']
  )
end

directory '/service/proteus-monitor-agent' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/service/proteus-monitor-agent/run' do
  source 'proteus-monitor-agent-daemontools.sh.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables(
    :install_dir => install_dir
  )
end
