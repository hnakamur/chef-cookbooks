#
# Cookbook Name:: nagios
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

# group 'apache' must be created before creating group 'nagios'.
package "httpd"

group 'nagios' do
  gid node[:nagios][:gid]
  members ['apache']
end

user 'nagios' do
  uid node[:nagios][:uid]
  gid 'nagios'
  comment 'Nagios monitoring tool'
end

package "nagios"

bash 'create_passwd' do
  code <<-EOH
    htpasswd -b -c /etc/nagios/passwd "#{node[:nagios][:web_interface_login]}" "#{node[:nagios][:web_interface_password]}" 
  EOH
end

template '/etc/nagios/objects/contacts.cfg' do
  source 'contacts.cfg.erb'
  user 'root'
  group 'root'
  mode '0644'
  variables(
    :alert_mail_recipient => node[:alert_mail_recipient]
  )
end

template '/etc/nagios/nagios.cfg' do
  source 'nagios.cfg.erb'
  user 'root'
  group 'root'
  mode '0644'
  variables(
    :date_format => node[:nagios][:date_format]
  )
end

template '/etc/nagios/objects/localhost.cfg' do
  source 'localhost.cfg.erb'
  user 'root'
  group 'root'
  mode '0644'
  variables(
    :localhost_ssh_notifications_enabled =>
      node[:nagios][:localhost_ssh_notifications_enabled],
    :localhost_http_notifications_enabled =>
      node[:nagios][:localhost_http_notifications_enabled]
  )
end

template '/etc/nagios/objects/hostgroups.cfg' do
  source 'hostgroups.cfg.erb'
  user 'root'
  group 'root'
  mode '0644'
  variables(
    :hostgroups => node[:nagios][:hostgroups]
  )
end

template '/etc/nagios/objects/hosts.cfg' do
  source 'hosts.cfg.erb'
  user 'root'
  group 'root'
  mode '0644'
  variables(
    :hosts => node[:nagios][:hosts]
  )
end

template '/etc/nagios/objects/services.cfg' do
  source 'services.cfg.erb'
  user 'root'
  group 'root'
  mode '0644'
  variables(
    :services => node[:nagios][:services]
  )
end

template '/etc/nagios/objects/commands.cfg' do
  source 'commands.cfg.erb'
  user 'root'
  group 'root'
  mode '0644'
  variables(
    :commands => node[:nagios][:commands]
  )
end

service 'nagios' do
  supports :reload => true
  action [:enable, :start]
end

cookbook_file '/etc/httpd/conf.d/nagios.conf' do
  source 'apache.nagios.conf'
end
bash 'apache_graceful_restart' do
  code <<-EOH
    service httpd graceful
  EOH
end
