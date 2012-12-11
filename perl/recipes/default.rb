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
perlbrew_home = node[:perl][:perlbrew_home]
version = node[:perl][:version]

bash 'install-perlbrew' do
  code <<-EOH
    export PERLBREW_ROOT=#{perlbrew_root} &&
    curl -kL http://install.perlbrew.pl | bash &&
    export PERLBREW_HOME=#{perlbrew_home} &&
    source #{perlbrew_home}/bashrc &&
    perlbrew init &&
    perlbrew install perl-#{version} &&
    perlbrew switch #{version} &&
    perlbrew install-cpanm
    cpanm --self-upgrade
  EOH
  creates perlbrew_home
end

bash 'update-root-bashrc' do
  code <<-EOH
    if ! grep -q '^export PERLBREW_HOME=' /root/.bashrc; then
      cat >> /root/.bashrc <<EOF

export PERLBREW_HOME=#{perlbrew_home}
source #{perlbrew_home}/bashrc
EOF
    fi
  EOH
end
