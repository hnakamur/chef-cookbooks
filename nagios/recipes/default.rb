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

version = node[:nagios][:version]
plugin_version = node[:nagios][:plugin_version]

bash "exclude-nagios-in-Base-repo" do
  code <<-EOH
    TMPFILE=/tmp/epel.repo.$$ &&
    awk -f #{File.dirname(File.dirname(__FILE__))}/files/default/exclude-pkg-in-epel.awk pkg=nagios /etc/yum.repos.d/epel.repo > $TMPFILE &&
    cp $TMPFILE /etc/yum.repos.d/epel.repo
  EOH
  not_if "grep -q '^exclude=.*nagios' /etc/yum.repos.d/epel.repo"
end

%w{ make gcc gd-devel }.each do |pkg|
  package pkg
end

remote_file "/usr/local/src/nagios-#{version}.tar.gz" do
  source "http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-#{version}.tar.gz"
  case version
  when "3.4.1"
    checksum "5c693f9af22410cc17d6da9c0df9bd65c47d787de3f937b5ccbda934131f8c8 "
  end
end

remote_file "/usr/local/src/nagios-plugins-#{plugin_version}.tar.gz" do
  source "http://prdownloads.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-#{plugin_version}.tar.gz"
  case plugin_version
  when "1.4.16"
    checksum "0caf07e0084e9b7f10fdd71cbd3ebabcd85ad78df64da360b51233b0e73b2bd"
  end
end

group 'nagios' do
  gid node[:nagios][:gid]
end

user 'nagios' do
  uid node[:nagios][:uid]
  gid 'nagios'
  shell '/bin/nologin'
  comment 'Nagios monitoring tool'
end

group 'nagcmd' do
  gid node[:nagios][:nagcmd_gid]
  members ['nagios', 'apache']
end

bash 'install_nagios' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf nagios-#{version}.tar.gz &&
    cd nagios &&
    ./configure --with-command-group=nagcmd &&
    make all &&
    make install &&
    make install-init &&
    make install-config &&
    make install-commandmode &&
    make install-webconf
  EOH
  not_if { FileTest.exists?("/etc/httpd/conf.d/nagios.conf") }
end

bash 'install_nagios_plugins' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf nagios-plugins-#{plugin_version}.tar.gz &&
    cd nagios-plugins-#{plugin_version} &&
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios &&
    make &&
    make install
  EOH
  not_if { FileTest.exists?("/usr/local/nagios/libexec/check_ssh") }
end

bash 'create_htpasswd.users' do
  code <<-EOH
    htpasswd -b -c /usr/local/nagios/etc/htpasswd.users "#{node[:nagios][:web_interface_login]}" "#{node[:nagios][:web_interface_password]}" 
  EOH
  not_if { FileTest.exists?("/usr/local/nagios/etc/htpasswd.users") }
end

template '/usr/local/nagios/etc/contacts.cfg' do
  source 'contacts.cfg.erb'
  variables(
    :alert_mail_recipient => node[:alert_mail_recipient]
  )
end

cookbook_file '/etc/httpd/conf.d/nagios.conf' do
  source 'apache.nagios.conf'
  not_if { FileTest.exists?('/root/.chef/nagios/apache.nagios.conf.created') }
end
bash 'apache_graceful_restart' do
  code <<-EOH
    service httpd graceful
  EOH
  not_if { FileTest.exists?('/root/.chef/nagios/apache.nagios.conf.created') }
end
directory '/root/.chef/nagios/apache.nagios.conf.created' do
  recursive true
end

template '/etc/nginx/https.location.d/https.nagios.conf' do
  source 'https.nagios.conf.erb'
  variables(
    :backend_port => node[:apache][:port]
  )
end
service 'nginx' do
  supports :reload => true
  action [:reload]
end

template '/usr/local/nagios/etc/nagios.cfg' do
  source 'nagios.cfg.erb'
  user 'nagios'
  group 'nagios'
  mode 0644
  variables(
    :date_format => node[:nagios][:date_format]
  )
end

template '/usr/local/nagios/etc/objects/localhost.cfg' do
  source 'localhost.cfg.erb'
  user 'nagios'
  group 'nagios'
  mode 0644
  variables(
    :localhost_ssh_notifications_enabled =>
      node[:nagios][:localhost_ssh_notifications_enabled],
    :localhost_http_notifications_enabled =>
      node[:nagios][:localhost_http_notifications_enabled]
  )
end

