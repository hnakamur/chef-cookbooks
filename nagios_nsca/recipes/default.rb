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

version = node[:nagios_nsca][:version]
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

template '/etc/nagios/nsca.cfg' do
  source 'nsca.cfg.erb'
  variables(
    :decryption_method => decryption_method,
    :decryption_password => decryption_password
  )
end

if node[:nagios_nsca][:install_type] == "client"

  bash 'install_nagios_send_nsca' do
    cwd "/usr/local/src"
    code <<-EOH
      tar xf /usr/local/src/nsca-#{version}.tar.gz &&
      cd nsca-#{version} &&
      ./configure \
          --sysconfdir=/etc/nagios \
          --localstatedir=/var/nagios &&
      make &&
      cp -p /usr/local/src/nsca-#{version}/src/send_nsca \
        /usr/local/nagios/bin/send_nsca
    EOH
    not_if { FileTest.exists?("/usr/local/nagios/bin/send_nsca") }
  end

else

  bash 'install_nagios_nsca' do
    cwd "/usr/local/src"
    code <<-EOH
      tar xf /usr/local/src/nsca-#{version}.tar.gz &&
      cd nsca-#{version} &&
      ./configure \
          --sysconfdir=/etc/nagios \
          --localstatedir=/var/nagios &&
      make &&
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

end
