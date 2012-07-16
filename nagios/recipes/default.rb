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
install_type = node[:nagios][:install_type]

bash "exclude-nagios-in-Base-repo" do
  code <<-EOH
    TMPFILE=/tmp/epel.repo.$$ &&
    awk -f #{File.dirname(File.dirname(__FILE__))}/files/default/exclude-pkg-in-epel.awk pkg=nagios /etc/yum.repos.d/epel.repo > $TMPFILE &&
    cp $TMPFILE /etc/yum.repos.d/epel.repo
  EOH
  not_if "grep -q '^exclude=.*nagios' /etc/yum.repos.d/epel.repo"
end

group 'nagios' do
  gid node[:nagios][:gid]
end

user 'nagios' do
  uid node[:nagios][:uid]
  gid 'nagios'
  comment 'Nagios monitoring tool'
end

if install_type == 'server'
  %w{ make gcc gd-devel }.each do |pkg|
    package pkg
  end

  remote_file "/usr/local/src/nagios-#{version}.tar.gz" do
    source "http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-#{version}.tar.gz"
    case version
    when "3.4.1"
      checksum "a5c693f9af22410cc17d6da9c0df9bd65c47d787de3f937b5ccbda934131f8c8"
    end
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
      ./configure \
        --sysconfdir=/etc/nagios \
        --localstatedir=/var/nagios \
        --with-command-group=nagcmd &&
      make all &&
      make install &&
      make install-init &&
      make install-config &&
      make install-commandmode &&
      make install-webconf
    EOH
    not_if { FileTest.exists?("/etc/httpd/conf.d/nagios.conf") }
  end

  directory '/var/nagios' do
    owner 'nagios'
    group 'nagcmd'
    recursive true
  end

  service 'nagios' do
    supports :reload => true
    action [:enable, :start]
  end

  bash 'create_htpasswd.users' do
    code <<-EOH
      htpasswd -b -c /etc/nagios/htpasswd.users "#{node[:nagios][:web_interface_login]}" "#{node[:nagios][:web_interface_password]}" 
    EOH
    not_if { FileTest.exists?("/etc/nagios/htpasswd.users") }
  end

  template '/etc/nagios/contacts.cfg' do
    source 'contacts.cfg.erb'
    variables(
      :alert_mail_recipient => node[:alert_mail_recipient]
    )
  end

  template '/etc/nagios/nagios.cfg' do
    source 'nagios.cfg.erb'
    user 'nagios'
    group 'nagios'
    mode 0644
    variables(
      :date_format => node[:nagios][:date_format]
    )
  end

  template '/etc/nagios/objects/localhost.cfg' do
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

  template '/etc/nagios/objects/templates.cfg' do
    source 'templates.cfg.erb'
    user 'nagios'
    group 'nagios'
    mode 0644
    variables(
      :generic_service => node[:nagios][:generic_service],
      :local_service => node[:nagios][:local_service]
    )
  end

  template '/etc/nagios/objects/hostgroups.cfg' do
    source 'hostgroups.cfg.erb'
    user 'nagios'
    group 'nagios'
    mode 0644
    variables(
      :hostgroups => node[:nagios][:hostgroups]
    )
  end

  template '/etc/nagios/objects/hosts.cfg' do
    source 'hosts.cfg.erb'
    user 'nagios'
    group 'nagios'
    mode 0644
    variables(
      :hosts => node[:nagios][:hosts]
    )
  end

  template '/etc/nagios/objects/services.cfg' do
    source 'services.cfg.erb'
    user 'nagios'
    group 'nagios'
    mode 0644
    variables(
      :services => node[:nagios][:services]
    )
  end

  template '/etc/nagios/objects/commands.cfg' do
    source 'commands.cfg.erb'
    user 'nagios'
    group 'nagios'
    mode 0644
    variables(
      :commands => node[:nagios][:commands]
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
end

##############################################################################
# nagios_plugins

plugins_version = node[:nagios][:plugins_version]

%w{ make gcc }.each do |pkg|
  package pkg
end

remote_file "/usr/local/src/nagios-plugins-#{plugins_version}.tar.gz" do
  source "http://prdownloads.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-#{plugins_version}.tar.gz"
  case plugins_version
  when "1.4.16"
    checksum "b0caf07e0084e9b7f10fdd71cbd3ebabcd85ad78df64da360b51233b0e73b2bd"
  end
end

bash 'install_nagios_plugins' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf nagios-plugins-#{plugins_version}.tar.gz &&
    cd nagios-plugins-#{plugins_version} &&
    ./configure \
        --sysconfdir=/etc/nagios \
        --localstatedir=/var/nagios \
        --with-nagios-user=nagios --with-nagios-group=nagios &&
    make &&
    make install
  EOH
  not_if { FileTest.exists?("/usr/local/nagios/libexec/check_ssh") }
end
