#
# Cookbook Name:: nagios_send_nsca
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

version = node[:nagios_nsca][:version]
decryption_method = node[:nagios_nsca][:decryption_method]
decryption_password = node[:nagios_nsca][:decryption_password]

bash 'install_send_nsca' do
  code <<-EOH
    mkdir -p /usr/local/nagios/bin &&
    cp -p /usr/local/src/nsca-#{version}/src/send_nsca \
      /usr/local/nagios/bin/send_nsca
  EOH
  not_if { FileTest.exists?("/usr/local/nagios/bin/send_nsca") }
end

directory '/usr/local/nagios/etc' do
  mode 0755
end

template '/usr/local/nagios/etc/send_nsca.cfg' do
  source 'send_nsca.cfg.erb'
  variables(
    :decryption_method => decryption_method,
    :decryption_password => decryption_password
  )
end
