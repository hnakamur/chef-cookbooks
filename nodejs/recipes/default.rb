#
# Cookbook Name:: nodejs
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

version = node[:nodejs][:version]

%w{ make gcc gcc-c++ openssl-devel }.each do |pkg|
  package pkg
end

remote_file "/usr/local/src/node-v#{version}.tar.gz" do
  source "http://nodejs.org/dist/v#{version}/node-v#{version}.tar.gz"
  case version
  when "0.8.6"
    checksum "dbd42800e69644beff5c2cf11a9d4cf6dfbd644a9a36ffdd5e8c6b8db9240854"
  when "0.8.1"
    checksum "0cda1325a010ce18f68501ae68e0ce97f0094e7a282c34a451f552621643a884"
  when "0.8.0"
    checksum "ecafca018b5109a28537633d0433d513f68b1bae7191a1821e8eaa84ccf128ee"
  when "0.6.19"
    checksum "4e33292477b01dfcf50bc628d580fd5af3e5ff807490ec46472b84100fb52fbb"
  end
end

bash 'install_nodejs' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf node-v#{version}.tar.gz &&
    cd node-v#{version} &&
    ./configure --prefix=/usr/local/node-v#{version} &&
    make &&
    make install
  EOH
  not_if { FileTest.exists?("/usr/local/node-v#{version}/bin/node") }
end
