#
# Cookbook Name:: stunnel
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

version = node[:stunnel][:version]

remote_file "/usr/local/src/stunnel-#{version}.tar.gz" do
  source "http://www.stunnel.org/downloads/stunnel-#{version}.tar.gz"

  case version
  when "4.53"
    checksum "3e640aa4c96861d10addba758b66e99e7c5aec8697764f2a59ca2268901b8e57"
  end
end

bash 'install_stunnel' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf stunnel-#{version}.tar.gz &&
    cd stunnel-#{version} &&
    ./configure --libdir=/usr/local/lib64 &&
    make &&
    make install &&
    install -m 755 tools/stunnel.init /etc/init.d/stunnel
  EOH
  not_if { FileTest.exists?("/usr/local/bin/stunnel") }
end

directory "/etc/stunnel" do
  owner 'root'
  group 'root'
  mode 0775
end

template '/etc/stunnel/stunnel.conf' do
  source 'stunnel.conf.erb'
  variables(
    :crt_file => node[:ssl_certificate][:crt_file],
    :key_file => node[:ssl_certificate][:key_file]
  )
#  not_if { FileTest.exists?("/etc/stunnel/stunnel.conf") }
end

service "stunnel" do
  supports :restart => true, :reload => true
  action [:enable, :start]
end
