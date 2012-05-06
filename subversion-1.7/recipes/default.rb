#
# Cookbook Name:: subversion
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

version = node[:subversion][:version]

apache_conf_top_dir = "/etc/httpd"
dav_svn_module_path = "modules/mod_dav_svn.so"
authz_svn_module_path = "modules/mod_authz_svn.so"

%w{ apr-devel apr-util-devel httpd-devel neon-devel openssl-devel sqlite-devel
    perl-ExtUtils-Embed }.each do |pkg|
  package pkg
end

remote_file "#{Chef::Config[:file_cache_path]}/subversion-#{version}.tar.gz" do
  source "http://ftp.riken.jp/net/apache/subversion/subversion-#{version}.tar.gz"
end

bash 'install_subversion' do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
    tar xf subversion-#{version}.tar.gz &&
    cd subversion-#{version} &&
    ./configure --with-apxs &&
    make &&
    make install &&
    apxs -ean dav_svn_module #{apache_conf_top_dir}/#{dav_svn_module_path} &&
    apxs -ean authz_svn_module #{apache_conf_top_dir}/#{authz_svn_module_path}
  EOH
  not_if { FileTest.exists?("/usr/local/bin/svn") }
end
