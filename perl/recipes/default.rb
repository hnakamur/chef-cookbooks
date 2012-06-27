#
# Cookbook Name:: perl
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

version = node[:perl][:version]

%w{ make gcc }.each do |pkg|
  package pkg
end

remote_file "/usr/local/src/perl-#{version}.tar.gz" do
  source "http://www.cpan.org/src/5.0/perl-#{version}.tar.gz"
  case version
  when "5.16.0"
    checksum "3a33eb21f61acdca2ea70394ba8abdf7d5abbcb6a7d81ad2f572e72bd7b36504"
  end
end

bash 'install_perl' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar -xzf perl-#{version}.tar.gz &&
    cd perl-#{version} &&
    ./Configure -des -Dprefix=/usr/local &&
    make &&
    make test &&
    make install
  EOH
  not_if { FileTest.exists?("/usr/local/bin/perl") }
end
