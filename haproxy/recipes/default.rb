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

%w{ make gcc }.each do |pkg|
  package pkg
end

remote_file "/usr/local/src/haproxy-#{version}.tar.gz" do
  dir = version.sub(/\.\d+$/, '')
  source "http://haproxy.1wt.eu/download/#{dir}/src/haproxy-#{version}.tar.gz"
  case version
  when "1.4.21"
    checksum "6e28575f0492def31c331faf9ead08225dd62153334880688f8a7c477c8c31a4"
  end
end

bash 'install_haproxy' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf haproxy-#{version}.tar.gz &&
    cd haproxy-#{version} &&
    make TARGET=linux26 CPU=x86_64 USE_PCRE=1 \
      SPEC_CFLAGS="-O2 -fno-strict-aliasing" &&
    make install
  EOH
  not_if { FileTest.exists?("/usr/local/sbin/haproxy") }
end

directory '/etc/haproxy' do
  mode "0755"
  owner "root"
  group "root"
end

template '/etc/haproxy/haproxy.cfg' do
  source 'haproxy.cfg.erb'
  variables(
    :nginx_http_port => node[:nginx][:http_port]
  )
#  not_if { FileTest.exists?("/etc/haproxy/haproxy.cfg") }
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
