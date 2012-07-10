#
# Cookbook Name:: php
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

remote_file "/usr/local/src/remi-release-6.rpm" do
  source "http://remi-mirror.dedipower.com/enterprise/remi-release-6.rpm"
end

bash "exclude-php-in-Base-repo" do
  code <<-EOH
    TMPFILE=/tmp/CentOS-Base.repo.$$ &&
    awk -f #{File.dirname(File.dirname(__FILE__))}/files/default/exclude-pkg-in-CentOS-Base.awk pkg=php /etc/yum.repos.d/CentOS-Base.repo > $TMPFILE &&
    cp $TMPFILE /etc/yum.repos.d/CentOS-Base.repo
  EOH
  not_if "grep -q '^exclude=.*php' /etc/yum.repos.d/CentOS-Base.repo"
end

package "remi-release" do
  source "/usr/local/src/remi-release-6.rpm"
end

bash "enable-remi-test" do
  code <<-EOH
    TMPFILE=/tmp/remi.repo.$$ &&
    awk -f #{File.dirname(File.dirname(__FILE__))}/files/default/enable-remi-test.awk /etc/yum.repos.d/remi.repo > $TMPFILE &&
    cp $TMPFILE /etc/yum.repos.d/remi.repo
  EOH
  only_if "awk -f #{File.dirname(File.dirname(__FILE__))}/files/default/check-enabled-remi-test.awk /etc/yum.repos.d/remi.repo"
end

%w{ php php-devel }.each do |pkg|
  package pkg
end

