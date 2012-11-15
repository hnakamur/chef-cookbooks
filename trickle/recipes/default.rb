#
# Cookbook Name:: trickle
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

version = node[:trickle][:version]

package "patch"
package "autoconf"
package "make"
package "gcc"
package "libevent-devel"

remote_file "/usr/local/src/trickle-#{version}.tar.gz" do
  source "http://monkey.org/~marius/trickle/trickle-#{version}.tar.gz"
  case version
  when "1.06"
    checksum "9ef83d243d7e91cd5333ef7a497d8fce5aa127d2600ec0b299302f31c37b8609"
  end
end

bash 'install_trickle' do
  file_dir = "#{File.dirname(File.dirname(__FILE__))}/files/default"
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf trickle-#{version}.tar.gz &&
    cd trickle-#{version} &&
    patch -p1 < #{file_dir}/configure.in.in_addr_t.patch &&
    autoconf &&
    ./configure &&
    make &&
    make install
  EOH
  creates "/usr/local/bin/trickle"
end
