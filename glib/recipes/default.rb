#
# Cookbook Name:: glib
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

version = node[:glib][:version]

%w{ make gcc gettext-devel }.each do |pkg|
  package pkg
end

remote_file "/usr/local/src/glib-#{version}.tar.xz" do
  dir = version.sub(/\.\d+$/, '')
  source "http://ftp.gnome.org/pub/gnome/sources/glib/#{dir}/glib-#{version}.tar.xz"
  case version
  when "2.32.4"
    checksum "a5d742a4fda22fb6975a8c0cfcd2499dd1c809b8afd4ef709bda4d11b167fae2"
  when "2.32.3"
    checksum "b65ceb462807e4a2f91c95e4293ce6bbefca308cb44a1407bcfdd9e40363ff4d"
  when "2.32.2"
    checksum "b1764abf00bac96e0e93e29fb9715ce75f3583579acac40648e18771d43d6136"
  end
end

bash 'install_glib' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf glib-#{version}.tar.xz &&
    cd glib-#{version} &&
    ./configure --libdir=/usr/local/lib64 &&
    make &&
    make install &&
    echo /usr/local/lib64 > /etc/ld.so.conf.d/glib-2.0.x86_64.conf &&
    ldconfig
  EOH
  not_if { FileTest.exists?("/etc/ld.so.conf.d/glib-2.0.x86_64.conf") }
end
