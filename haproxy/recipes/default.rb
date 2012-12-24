#
# Cookbook Name:: haproxy
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

version = node[:haproxy][:version]
major_ver = version.sub(/[-.][^-.]*$/, '')

package "make"
package "gcc"
if major_ver == "1.5"
  ssl_options = "USE_OPENSSL=1 USE_ZLIB=1"
  package "openssl-devel"
  package "zlib-devel"
else
  ssl_options = ""
end

remote_file "/usr/local/src/haproxy-#{version}.tar.gz" do
  dev = version =~ /dev/ ? 'devel/' : ''
  source "http://haproxy.1wt.eu/download/#{major_ver}/src/#{dev}haproxy-#{version}.tar.gz"
  case version
  when "1.5-dev15"
    checksum "417d746c6ff179b290410b8640b699a5f2b98cdb916ace4656d7d1ea79880047"
  when "1.4.22"
    checksum "ba221b3eaa4d71233230b156c3000f5c2bd4dace94d9266235517fe42f917fc6"
  when "1.4.21"
    checksum "6e28575f0492def31c331faf9ead08225dd62153334880688f8a7c477c8c31a4"
  end
end

bash 'install_haproxy' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf haproxy-#{version}.tar.gz &&
    cd haproxy-#{version} &&
    make TARGET=linux2628 CPU=native USE_STATIC_PCRE=1 #{ssl_options} &&
    make install
  EOH
  creates "/usr/local/sbin/haproxy"
end

directory '/etc/haproxy' do
  mode "0755"
  owner "root"
  group "root"
end

template '/etc/haproxy/haproxy.cfg' do
  source 'haproxy.cfg.erb'
  variables(
    :ssl_crt => node.haproxy.ssl_crt,
    :nginx_socket => node.haproxy.nginx_socket
  )
  not_if { FileTest.exists?("/etc/haproxy/haproxy.cfg") }
end

template '/etc/init.d/haproxy' do
  source 'haproxy.init.erb'
  mode "0755"
  owner "root"
  group "root"
  variables(
    :prefix => '/usr/local'
  )
  not_if { FileTest.exists?("/etc/init.d/haproxy") }
end

service "haproxy" do
  supports :restart => true, :reload => true
  action [:enable, :start]
end
