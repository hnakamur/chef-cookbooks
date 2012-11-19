#
# Cookbook Name:: nagios_nrpe
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

package "nagios-plugins-nrpe"
package "nrpe"

group 'nrpe' do
  gid node[:nagios_nrpe][:gid]
end

user 'nrpe' do
  uid node[:nagios_nrpe][:uid]
  gid 'nrpe'
  comment 'Nagios Remote Plugin Executor'
end

directory '/etc/nagios' do
  user 'nagios'
  group 'nagios'
  mode '0755'
end

template '/etc/nagios/nrpe.cfg' do
  source 'nrpe.cfg.erb'
  user 'nagios'
  group 'nagios'
  mode '0644'
  variables(
    :allowed_hosts => node[:nagios_nrpe][:server_ip],
    :commands => node[:nagios_nrpe][:commands]
  )
end

##############################################################################
# xinetd setup

package 'xinetd'

template '/etc/xinetd.d/nrpe' do
  source 'nrpe.xinetd.conf.erb'
  user 'root'
  group 'root'
  mode '0600'
  variables(
    :server_ip => node[:nagios_nrpe][:server_ip]
  )
end

ruby_block "nagios_nrpe_edit_etc_services" do
  require "#{File.dirname(File.dirname(__FILE__))}/files/default/services_file.rb"
  file = ServicesFile.load
  new_line = 'nrpe            5666/tcp                        # Nagios Remote Plugin Executor NRPE'
  block do
    file.lines.insert(file.index_for_port(5666), new_line)
    file.save
  end
  not_if { file.lines.index(new_line) }
end

service 'xinetd' do
  supports :restart => true, :reload => true
  action [:enable, :start, :reload]
end
