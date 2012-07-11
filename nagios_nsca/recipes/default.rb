#
# Cookbook Name:: nagios_nsca
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

require "#{File.dirname(File.dirname(__FILE__))}/files/default/text_file.rb"
puts "@@@@ after require"

version = node[:nagios_nsca][:version]
install_type = node[:nagios_nsca][:install_type]
decryption_method = node[:nagios_nsca][:decryption_method]
decryption_password = node[:nagios_nsca][:decryption_password]

%w{ make gcc libmcrypt-devel }.each do |pkg|
  package pkg
end

remote_file "/usr/local/src/nsca-#{version}.tar.gz" do
  source "http://prdownloads.sourceforge.net/sourceforge/nagios/nsca-#{version}.tar.gz"
  case version
  when "2.7.2"
    checksum "fb41e3b536735235056643fb12187355c6561b9148996c093e8faddd4fced571"
  end
end

bash 'build_nsca' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf nsca-#{version}.tar.gz &&
    cd nsca-#{version} &&
    ./configure &&
    make all
  EOH
  not_if { FileTest.exists?("/usr/local/src/nsca-#{version}/src/nsca") }
end

case install_type
when "receiver"
  template '/usr/local/nagios/etc/nsca.cfg' do
    source 'nsca.cfg.erb'
    variables(
      :decryption_method => decryption_method,
      :decryption_password => decryption_password
    )
  end

  bash 'install_nsca' do
    code <<-EOH
      cp -p /usr/local/src/nsca-#{version}/src/nsca \
        /usr/local/nagios/bin/nsca &&
      install -m 755 -o root -g root \
        /usr/local/src/nsca-#{version}/init-script \
        /etc/init.d/nsca
    EOH
    not_if { FileTest.exists?("/usr/local/nagios/bin/nsca") }
  end

puts "@@@@ before service nsca"
  service 'nsca' do
    action [:enable, :start]
  end
puts "@@@@ after service nsca"

  firewall_config_modified = false

  ruby_block "edit_firewall_config" do
    file = TextFile.load "/etc/sysconfig/iptables"
    new_line = \
      "-A INPUT -m state --state NEW -m tcp -p tcp --dport 5667 -j ACCEPT"
    block do
puts "@@@@ line count=#{file.lines.size}"
      file.lines.insert(
        file.lines.index(
          "-A INPUT -j REJECT --reject-with icmp-host-prohibited"
        ),
        new_line
      )
      file.save
      firewall_config_modified = true
    end
#    not_if { file.lines.index(new_line) }
  end

  service "iptables" do
    supports :restart => true
    action [:restart]
    only_if { firewall_config_modified }
  end
when "sender"
  bash 'install_send_nsca' do
    code <<-EOH
      cp -p /usr/local/src/nsca-#{version}/src/send_nsca \
        /usr/local/nagios/bin/send_nsca
    EOH
    not_if { FileTest.exists?("/usr/local/nagios/bin/send_nsca") }
  end
end
