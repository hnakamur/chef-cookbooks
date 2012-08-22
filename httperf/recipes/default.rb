#
# Cookbook Name:: httperf
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

version = node[:httperf][:version]

%w{ make gcc openssl-devel }.each do |pkg|
  package pkg
end

remote_file "/usr/local/src/httperf-#{version}.tar.gz" do
  source "http://httperf.googlecode.com/files/httperf-#{version}.tar.gz"
  case version
  when "0.9.0"
    checksum "e1a0bf56bcb746c04674c47b6cfa531fad24e45e9c6de02aea0d1c5f85a2bf1c"
  end
end

bash 'install_httperf' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf httperf-#{version}.tar.gz &&
    cd httperf-#{version} &&
    ./configure &&
    make &&
    make install
  EOH
  not_if { FileTest.exists?("/usr/local/bin/httperf") }
end
