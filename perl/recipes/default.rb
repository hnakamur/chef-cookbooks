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

perlbrew_root = node[:perl][:perlbrew_root]
version = node[:perl][:version]

%w{ make gcc }.each do |pkg|
  package pkg
end

bash 'install_perlbrew' do
  code <<-EOH
    export PERLBREW_ROOT=#{perlbrew_root} &&
    curl -kL http://install.perlbrew.pl | bash &&
    echo 'source #{perlbrew_root}/etc/bashrc' >> /root/.bashrc &&
    . /root/.bashrc &&
    perlbrew init
  EOH
  not_if { FileTest.exists?("#{perlbrew_root}/bin/perlbrew") }
end

bash 'install_perl' do
  code <<-EOH
    perlbrew install perl-#{version} --as #{version} &&
    perlbrew switch #{version} &&
    perlbrew install-cpanm &&
    cpanm --self-upgrade
  EOH
  not_if { FileTest.exists?("#{perlbrew_root}/perls/#{version}/bin/perl") }
end
