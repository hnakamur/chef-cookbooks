#
# Cookbook Name:: erlang
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

version = node[:erlang][:version]

%w{ make gcc ncurses-devel openssl-devel unixODBC-devel java-1.7.0-openjdk-devel }.each do |pkg|
  package pkg
end

remote_file "/usr/local/src/otp_src_#{version}.tar.gz" do
  source "http://www.erlang.org/download/otp_src_#{version}.tar.gz"
  case version
  when "R15B01"
    checksum "f94f7de7328af3c0cdc42089c1a4ecd03bf98ec680f47eb5e6cddc50261cabde"
  end
end

bash 'install_erlang' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf otp_src_#{version}.tar.gz &&
    cd otp_src_#{version} #&&
    export LANG=C &&
    ./configure &&
    make &&
    make install
  EOH
  not_if { FileTest.exists?("/usr/local/bin/erl") }
end
