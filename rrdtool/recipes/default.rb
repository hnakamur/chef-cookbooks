#
# Cookbook Name:: rrdtool
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

version = node[:rrdtool][:version]

%w{ make gcc pango-devel }.each do |pkg|
  package pkg
end

remote_file "/usr/local/src/rrdtool-#{version}.tar.gz" do
  source "http://oss.oetiker.ch/rrdtool/pub/rrdtool-#{version}.tar.gz"
  case version
  when "1.4.7"
    checksum "956aaf431c955ba88dd7d98920ade3a8c4bad04adb1f9431377950a813a7af11"
  end
end

bash 'install_rrdtool' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf rrdtool-#{version}.tar.gz &&
    cd rrdtool-#{version} &&
    PKG_CONFIG_PATH=/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig \
      ./configure --enable-perl-site-install &&
    make &&
    make install
  EOH
  not_if { FileTest.exists?("/opt/rrdtool-#{version}") }
end
