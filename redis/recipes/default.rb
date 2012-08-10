#
# Cookbook Name:: redis
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

version = node[:redis][:version]

%w{ make gcc }.each do |pkg|
  package pkg
end

remote_file "/usr/local/src/redis-#{version}.tar.gz" do
  source "http://redis.googlecode.com/files/redis-#{version}.tar.gz"
  case version
  when "2.4.16"
    checksum "d35cc89d73aa1ff05af5f1380a4411c828979b3b446f5caf8b5720225b38e15b"
  end
end

bash 'install_redis' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf redis-#{version}.tar.gz &&
    cd redis-#{version} &&
    make &&
    make install
  EOH
  not_if { FileTest.exists?("/usr/local/bin/redis-server") }
end
