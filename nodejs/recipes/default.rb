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

package 'git'
package 'make'
package 'gcc'
package 'gcc-c++'
package 'openssl-devel'

git '/usr/local/nvm' do
  repository "https://github.com/creationix/nvm.git"
  reference "master"
  action :sync
end

bash 'install_nodejs' do
  code <<-EOH
    . /usr/local/nvm/nvm.sh &&
    nvm install v#{version} &&
    nvm alias default #{version}
  EOH
  creates "/usr/local/nvm/v#{version}"
end

bash 'update-root-bashrc-for-nvm' do
  code <<-EOH
    if ! grep -qF '^. /usr/local/nvm/nvm.sh' /root/.bashrc; then
      cat >> /root/.bashrc <<EOF

. /usr/local/nvm/nvm.sh
EOF
    fi
  EOH
end
