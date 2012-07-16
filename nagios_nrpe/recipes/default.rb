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

version = node[:nagios_nrpe][:version]

remote_file "/usr/local/src/nrpe-#{version}.tar.gz" do
  source "http://prdownloads.sourceforge.net/sourceforge/nagios/nrpe-#{version}.tar.gz"
  case version
  when "2.13"
    checksum "bac8f7eb9daddf96b732a59ffc5762b1cf073fb70f6881d95216ebcd1254a254"
  end
end

bash 'install_nrpe' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf nrpe-#{version}.tar.gz &&
    cd nrpe-#{version} &&
    ./configure \
        --sysconfdir=/etc/nagios \
        --localstatedir=/var/nagios \
        --enable-ssl &&
    make all &&
    mkdir -p /usr/local/nagios/bin/ &&
    install -m 0755 -o nagios -g nagios \
      /usr/local/src/nrpe-#{version}/src/check_nrpe \
      /usr/local/nagios/bin/ &&
    install -m 0774 -o nagios -g nagios \
      /usr/local/src/nrpe-#{version}/src/nrpe \
      /usr/local/nagios/bin/
  EOH
  not_if { FileTest.exists?("/usr/local/nagios/bin/nrpe") }
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

ruby_block "nagios_nrpe_edit_firewall_config" do
  require "#{File.dirname(File.dirname(__FILE__))}/files/default/text_file.rb"
  file = TextFile.load "/etc/sysconfig/iptables"
  new_line = \
    "-A INPUT -m state --state NEW -m tcp -p tcp --dport 5666 -j ACCEPT"
  block do
    file.lines.insert(
      file.lines.index(
        "-A INPUT -j REJECT --reject-with icmp-host-prohibited"
      ),
      new_line
    )
    file.save
    system "service iptables restart"
  end
  not_if { file.lines.index(new_line) }
end
