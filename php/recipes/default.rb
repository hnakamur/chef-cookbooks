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

package "remi-release" do
  source "/usr/local/src/remi-release-6.rpm"
end

bash "enable-remi" do
  code <<-'EOH'
    f=/etc/yum.repos.d/remi.repo
    enabled=`sed -ne '/^\[remi\]/,/^$/{/^enabled=/{s/enabled=//;p;q}}' $f`
    if [ "$enabled" = 0 ]; then
      sed -i -e '/^\[remi\]/,/^$/s/enabled=0/enabled=1/' $f
    fi
  EOH
end

bash "exclude-php-in-Base-repo" do
  code <<-'EOH'
f=/etc/yum.repos.d/CentOS-Base.repo
php_excluded=`sed -ne '/^\[base\]/,/^$/{
/^exclude=.*php/{c\
1
p;q}
/^exclude=/{c\
0
p;q}
}' $f`
case $php_excluded in
1) # already excluded, do nothing
  ;;
0) # modify exclude line
  sed -i -e '/^\[base\]/,/^$/{
s/exclude=.*/&,php\*/
}' $f
  ;;
*) # add exclude line
  sed -i -e '/^\[base\]/,/^$/{
/^$/i\
exclude=php*
}' $f
  ;;
esac
  EOH
end

yum_package "php" do
  action :install
  flush_cache [ :before ]
end

yum_package "php-devel"
yum_package "php-fpm"
yum_package "php-intl"
yum_package "php-mbstring"
yum_package "php-mysql"
yum_package "php-pdo"
yum_package "php-pear"
yum_package "php-pecl-apc"
yum_package "php-process"
yum_package "php-soap"
yum_package "php-xml"

bash "modify-php.ini" do
  code <<-'EOH'
    zone=`sed -ne '/^ZONE=/{s/ZONE="\([^"]*\)"/\1/;p;q}' /etc/sysconfig/clock`
    sed -i -e 's:^;\(date\.timezone =\).*:\1 '$zone':' /etc/php.ini
  EOH
end
