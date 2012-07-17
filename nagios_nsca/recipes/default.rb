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

version = node[:nagios_nsca][:version]
decryption_method = node[:nagios_nsca][:decryption_method]
decryption_password = node[:nagios_nsca][:decryption_password]

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

service 'nsca' do
  supports :restart => true, :reload => false
  action [:enable, :start]
end
ruby_block "nsca_force_start_nsca" do
  block do
    system "service nsca start"
  end
end

ruby_block "nsca_edit_firewall_config" do
  file = TextFile.load "/etc/sysconfig/iptables"
  new_line = \
    "-A INPUT -m state --state NEW -m tcp -p tcp --dport 5667 -j ACCEPT"
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
  not_if { file.lines.empty? || file.lines.index(new_line) }
end
