#
# Cookbook Name:: tsung
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

version = node[:tsung][:version]

%w{ gnuplot python-matplotlib pygtk2 }.each do |pkg|
  package pkg
end

remote_file "/usr/local/src/tsung-#{version}.tar.gz" do
  source "http://tsung.erlang-projects.org/dist/tsung-#{version}.tar.gz"
  case version
  when "1.4.2"
    checksum "66608f551a8381dd853ead64c0e44255e64f25db05d3458a2e9c557d72a34d6e"
  end
end

bash 'install_tsung' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf tsung-#{version}.tar.gz &&
    cd tsung-#{version} &&
    ./configure &&
    make &&
    make install
  EOH
  not_if { FileTest.exists?("/usr/local/bin/tsung") }
end

# Template.pm is needed by /usr/local/lib/tsung/bin/tsung_stats.pl
bash 'install_Template.pm' do
  code <<-EOH
    cpanm Template
  EOH
end
