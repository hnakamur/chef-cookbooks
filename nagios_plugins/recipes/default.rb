#
# Cookbook Name:: nagios_plugins
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

version = node[:nagios_plugins][:version]

%w{ make gcc }.each do |pkg|
  package pkg
end

remote_file "/usr/local/src/nagios-plugins-#{version}.tar.gz" do
  source "http://prdownloads.sourceforge.net/sourceforge/nagiosplug/nagios-plugins-#{version}.tar.gz"
  case version
  when "1.4.16"
    checksum "b0caf07e0084e9b7f10fdd71cbd3ebabcd85ad78df64da360b51233b0e73b2bd"
  end
end

bash 'install_nagios_plugins' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf nagios-plugins-#{version}.tar.gz &&
    cd nagios-plugins-#{version} &&
    ./configure --with-nagios-user=nagios --with-nagios-group=nagios &&
    make &&
    make install
  EOH
  not_if { FileTest.exists?("/usr/local/nagios/libexec/check_ssh") }
end
