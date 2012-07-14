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

version = node[:munin][:version]

group 'munin' do
  gid node[:munin][:gid]
end

user 'munin' do
  uid node[:munin][:uid]
  gid 'munin'
  shell '/sbin/nologin'
  comment 'Munin networked resource monitoring tool'
end

%w{ make gcc cronie }.each do |pkg|
  package pkg
end

bash 'munin_install_perl_modules' do
  code <<-EOH
    cpanm Time::HiRes Storable Digest::MD5 HTML::Template Text::Balanced \
      Params::Validate Net::SSLeay Getopt::Long \
      File::Copy::Recursive CGI::Fast IO::Socket::INET6 Log::Log4perl \
      Log::Dispatch Log::Dispatch::FileRotate MIME::Lite \
      Mail::Sendmail URI FCGI
      # These modules were not found.
      # TimeDate IPC::Shareable Mail::Sender MailTools
  EOH
end

remote_file "/usr/local/src/munin-#{version}.tar.gz" do
  source "http://downloads.sourceforge.net/project/munin/stable/#{version}/munin-#{version}.tar.gz"
  case version
  when "2.0.2"
    checksum "e8a5266a85cde8b89a97fb7463a56a7ac9c038035b952e36047b7d599bb9181b"
  end
end

bash 'install_munin' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf munin-#{version}.tar.gz &&
    cd munin-#{version} &&
    patch -p0 < #{File.dirname(File.dirname(__FILE__))}/files/default/use_cgiurl_graph_in_dynazoom.html.patch &&
    make &&
    make install &&
    chmod 777 /opt/munin/log/munin /var/opt/munin/cgi-tmp
  EOH
  not_if { FileTest.exists?("/opt/munin/lib/munin-asyncd") }
end

bash 'create_munin-htpasswd' do
  code <<-EOH
    htpasswd -b -c /etc/opt/munin/munin-htpasswd "#{node[:munin][:web_interface_login]}" "#{node[:munin][:web_interface_password]}" 
  EOH
  not_if { FileTest.exists?("/etc/opt/munin/munin-htpasswd") }
end

cookbook_file "/etc/cron.d/munin" do
  source "munin.cron"
  owner 'root'
  group 'root'
  mode '0644'
  not_if { FileTest.exists?("/etc/cron.d/munin") }
end

service 'crond' do
  action [:enable, :start]
end

template '/etc/opt/munin/munin.conf' do
  source 'munin.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    :host_tree_configs => node[:munin][:host_tree_configs]
  )
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

template '/etc/nginx/https.location.d/https.munin.conf' do
  source 'https.munin.conf.erb'
  variables(
    :backend_port => node[:apache][:port]
  )
end
service 'nginx' do
  supports :reload => true
  action [:reload]
end
