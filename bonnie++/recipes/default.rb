#
# Cookbook Name:: bonnie++
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

version = node[:"bonnie++"][:version]

%w{ make gcc }.each do |pkg|
  package pkg
end

remote_file "/usr/local/src/bonnie++-#{version}.tgz" do
  source "http://www.coker.com.au/bonnie++/bonnie++-#{version}.tgz"
  case version
  when "1.03e"
    checksum "cb3866116634bf65760b6806be4afa7e24a1cad6f145c876df8721f01ba2e2cb"
  end
end

bash 'install_bonnie++' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf /usr/local/src/bonnie++-#{version}.tgz &&
    cd bonnie++-#{version} &&
    ./configure &&
    make &&
    make install
  EOH
  not_if { FileTest.exists?("/usr/local/sbin/bonnie++") }
end
