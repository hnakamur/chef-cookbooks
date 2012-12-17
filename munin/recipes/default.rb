#
# Cookbook Name:: munin
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

group 'munin' do
  gid node[:munin][:gid]
end

user 'munin' do
  uid node[:munin][:uid]
  gid 'munin'
  shell '/sbin/nologin'
  comment 'Munin networked resource monitoring tool'
end

package "munin"
package "munin-cgi"
package "mod_fcgid"

bash 'create_munin-htpasswd' do
  code <<-EOH
    htpasswd -b -c /etc/munin/munin-htpasswd "#{node[:munin][:web_interface_login]}" "#{node[:munin][:web_interface_password]}" 
  EOH
  not_if { FileTest.exists?("/etc/munin/munin-htpasswd") }
end

directory '/var/lib/munin/cgi-tmp' do
  owner 'munin'
  group 'munin'
  mode '0777'
end

template '/etc/munin/munin.conf' do
  source 'munin.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :data_retention_period_in_days => node[:munin][:data_retention_period_in_days],
    :host_tree_configs => node[:munin][:host_tree_configs]
  )
end

cookbook_file '/etc/cron.d/munin' do
  source 'munin.cron'
  owner 'root'
  group 'root'
  mode '0644'
end

cookbook_file '/etc/httpd/conf.d/munin.conf' do
  source 'apache.munin.conf'
  owner 'root'
  group 'root'
  mode '0644'
end
bash 'munin_apache_graceful_restart' do
  code <<-EOH
    service httpd graceful
  EOH
end
