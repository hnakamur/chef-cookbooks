#
# Cookbook Name:: mysql
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

version = node[:mysql][:version]
rpm_version = node[:mysql][:rpm_version]
install_type = node[:mysql][:install_type]

bash "exclude-mysql-in-Base-repo" do
  code <<-EOH
    TMPFILE=/tmp/CentOS-Base.repo.$$ &&
    awk -f #{File.dirname(File.dirname(__FILE__))}/files/default/exclude-pkg-in-CentOS-Base.awk pkg=mysql /etc/yum.repos.d/CentOS-Base.repo > $TMPFILE &&
    cp $TMPFILE /etc/yum.repos.d/CentOS-Base.repo
  EOH
  not_if "grep -q '^exclude=.*mysql' /etc/yum.repos.d/CentOS-Base.repo"
end

# This cookbook assumes rpm_version >= 5.5.6
#
# http://dev.mysql.com/doc/refman/5.5/en/linux-installation-rpm.html
# Before MySQL 5.5.6, MySQL-shared-compat also includes the libraries for the
# current release, so if you install it, you should not also install
# MySQL-shared. As of 5.5.6, MySQL-shared-compat does not include the current
# library version, so there is no conflict.
# 
# As of MySQL 5.5.23, the MySQL-shared-compat RPM package enables users of Red
# Hat-privided mysql-*-5.1 RPM packages to migrate to Oracle-provided
# MySQL-*-5.5 packages. MySQL-shared-compat replaces the Red Hat mysql-libs
# package by replacing libmysqlclient.so files of the latter package, thus
# satisfying dependencies of other packages on mysql-libs. This change affects
# only users of Red Hat (or Red Hat-compatible) RPM packages. Nothing is
# different for users of Oracle RPM packages

remote_file "/usr/local/src/MySQL-shared-compat-#{rpm_version}.el6.x86_64.rpm" do
  source "http://dev.mysql.com/get/Downloads/MySQL-#{version}/MySQL-shared-compat-#{rpm_version}.el6.x86_64.rpm/from/http://cdn.mysql.com/"
  case rpm_version
  when "5.5.29-1"
    checksum "c32e491e3167815a373eeaadaca0897148e7507aa1a92f12f8eeb9c08698b954"
  when "5.5.28-1"
    checksum "99cde41f2664355535bb46eaf5b1ab5971067e2a2c6378a66c9d9c30b1ca3c6b"
  when "5.5.27-1"
    checksum "ee22c24f9c6a423884624adff4a982a49856c2fab610f5ec4ab9df7f90cbe6ff"
  when "5.5.25a-1"
    checksum "7df834438f49c16e36842bde0db6da56596c6f8d2b053ea7e6f5c57367d1974d"
  end
end

remote_file "/usr/local/src/MySQL-shared-#{rpm_version}.el6.x86_64.rpm" do
  source "http://dev.mysql.com/get/Downloads/MySQL-#{version}/MySQL-shared-#{rpm_version}.el6.x86_64.rpm/from/http://cdn.mysql.com/"
  case rpm_version
  when "5.5.29-1"
    checksum "81bd7d1f17f7c025ee4c37bbf64ea38f8fb443fe137e558a48316117eb65c827"
  when "5.5.28-1"
    checksum "4b37baaaa44161c98a0718ea8626d4c793cbe70562f5014c5941992b8ebc6861"
  when "5.5.27-1"
    checksum "84badc2cadc9f8cbd691647aba58f94ab6e0cbcde4163185f166a92aa545551c"
  when "5.5.25a-1"
    checksum "eb80d2401b48a4139e98fc9f244374f5a0bf54f46ba6e1c7be6890fb961df969"
  end
end

remote_file "/usr/local/src/MySQL-server-#{rpm_version}.el6.x86_64.rpm" do
  source "http://dev.mysql.com/get/Downloads/MySQL-#{version}/MySQL-server-#{rpm_version}.el6.x86_64.rpm/from/http://cdn.mysql.com/"
  case rpm_version
  when "5.5.29-1"
    checksum "bce0132e86a23b19e1ba229e0411de39cdbde538f922c244d056ecaf3f054cb1"
  when "5.5.28-1"
    checksum "266279ed0aeef33e476a2a9efe989dc928bb21e6eb6971265024444da1c328e3"
  when "5.5.27-1"
    checksum "fe7a5be7634bd10420f81ee176ab7b53662d76a8b813b7a2f563cc207413db32"
  when "5.5.25a-1"
    checksum "fecbea3317e9561df99efe69e77d4b57fc75f9654a04838652c2dcfb704b4e27"
  end
  only_if { install_type == 'server' }
end

remote_file "/usr/local/src/MySQL-client-#{rpm_version}.el6.x86_64.rpm" do
  source "http://dev.mysql.com/get/Downloads/MySQL-#{version}/MySQL-client-#{rpm_version}.el6.x86_64.rpm/from/http://cdn.mysql.com/"
  case rpm_version
  when "5.5.29-1"
    checksum "b28d402b8962638ec4c3373a5449814af817e14fbc9b063ece082d966ca4859e"
  when "5.5.28-1"
    checksum "4fb0261a4006f49d5e50db9509cd5232c0e4e7af7af60d69dda36f856fa2c3f0"
  when "5.5.27-1"
    checksum "76c13c73e29a3eccf6be008bc837b13c24a45736e4e0b7203e99140bbaa5914f"
  when "5.5.25a-1"
    checksum "cd29cad2b84c923b4091084b010cc14e81a847e26099904a572623863490f74e"
  end
end

remote_file "/usr/local/src/MySQL-devel-#{rpm_version}.el6.x86_64.rpm" do
  source "http://dev.mysql.com/get/Downloads/MySQL-#{version}/MySQL-devel-#{rpm_version}.el6.x86_64.rpm/from/http://cdn.mysql.com/"
  case rpm_version
  when "5.5.29-1"
    checksum "76defd44a97f81279881c3f0753f3bab3aed4148906735ddf72ae6ce5f95a9f1"
  when "5.5.28-1"
    checksum "1a7e05b7f64a23b600b05afc4d3c74211477fcdfcf415476af5dd225bde13c8b"
  when "5.5.27-1"
    checksum "84badc2cadc9f8cbd691647aba58f94ab6e0cbcde4163185f166a92aa545551c"
  when "5.5.25a-1"
    checksum "408aea290ef725e9db2bf8aa46447ec78ee358f852376dedd80af46383797794"
  end
end

# Install MySQL-shared-compat then unisntall mysql-libs.
#
# # rpm -q --provides MySQL-shared-compat
# libmysqlclient.so.12()(64bit)  
# libmysqlclient.so.14()(64bit)  
# libmysqlclient.so.14(libmysqlclient_14)(64bit)  
# libmysqlclient.so.15()(64bit)  
# libmysqlclient.so.15(libmysqlclient_15)(64bit)  
# libmysqlclient.so.16()(64bit)  
# libmysqlclient.so.16(libmysqlclient_16)(64bit)  
# libmysqlclient_r.so.12()(64bit)  
# libmysqlclient_r.so.14()(64bit)  
# libmysqlclient_r.so.14(libmysqlclient_14)(64bit)  
# libmysqlclient_r.so.15()(64bit)  
# libmysqlclient_r.so.15(libmysqlclient_15)(64bit)  
# libmysqlclient_r.so.16()(64bit)  
# libmysqlclient_r.so.16(libmysqlclient_16)(64bit)  
# mysql-libs  
# MySQL-shared-compat = 5.5.28-1.el6
# MySQL-shared-compat(x86-64) = 5.5.28-1.el6
bash "install-MySQL-shared-compat" do
  code <<-EOH
   rpm -i /usr/local/src/MySQL-shared-compat-#{rpm_version}.el6.x86_64.rpm
  EOH
  not_if 'rpm -q MySQL-shared-compat > /dev/null'
end
package "mysql-libs" do
  action :remove
  only_if 'rpm -q mysql-libs > /dev/null'
end

# We need to uninstall mysql package to avoid conflict with MySQL-* packages.
package "mysql" do
  action :remove
  only_if 'rpm -q mysql > /dev/null'
end

# As of 5.5.29-1, we cannot install both MySQL-shared and MySQL-shared-compat
# at the same time due to the error below.
# ---
# STDERR: error: Failed dependencies:
#        mysql-libs conflicts with MySQL-shared-5.5.29-1.el6.x86_64
# ---
# Since postfix needs mysql-libs, which is provided by MySQL-shared-compat,
# So we are forced not to install MySQL-shared
#bash "install-MySQL-shared" do
#  code <<-EOH
#    rpm -i /usr/local/src/MySQL-shared-#{rpm_version}.el6.x86_64.rpm
#  EOH
#  not_if 'rpm -q MySQL-shared > /dev/null'
#end

bash "create-mysqlclient_r.so-symlink" do
  code <<-EOH
ln -s libmysqlclient_r.so.16 /usr/lib64/libmysqlclient_r.so
  EOH
  creates "/usr/lib64/libmysqlclient_r.so"
end

bash "install-MySQL-server" do
  code <<-EOH
    if ! rpm -q MySQL-server; then
      rpm -i /usr/local/src/MySQL-server-#{rpm_version}.el6.x86_64.rpm
    fi
  EOH
  only_if { install_type == 'server' }
end

bash "install-MySQL-client" do
  code <<-EOH
    rpm -i /usr/local/src/MySQL-client-#{rpm_version}.el6.x86_64.rpm
  EOH
  not_if 'rpm -q MySQL-client > /dev/null'
end

bash "install-MySQL-devel" do
  code <<-EOH
    rpm -i /usr/local/src/MySQL-devel-#{rpm_version}.el6.x86_64.rpm
  EOH
  not_if 'rpm -q MySQL-devel > /dev/null'
end

template '/etc/my.cnf' do
  source 'my.cnf.erb'
  variables(
    :expire_logs_days => node[:mysql][:expire_logs_days],
    :long_query_time => node[:mysql][:long_query_time]
  )
  only_if { install_type == 'server' }
end

directory '/var/run/mysqld' do
  mode 0755
  owner "mysql"
  group "mysql"
  recursive true
  only_if { install_type == 'server' }
end

file "/var/log/mysqld-slow.log" do
  owner "mysql"
  group "mysql"
  mode 0644
end

bash 'mysql_install_db' do
  code <<-EOH
    mysql_install_db
    touch /root/.chef/.mysql_install_db_complete
  EOH
  only_if do
    install_type == 'server' &&
    !File.exists?('/root/.chef/.mysql_install_db_complete')
  end
end

service 'mysql' do
  supports :restart => true
  action [:enable, :start]
  only_if { install_type == 'server' }
end

bash 'mysql_secure_installation' do
  code <<-EOH
    mysql -uroot <<EOF && touch /root/.chef/.mysql_secure_installation_complete
-- remove anonymous users
DELETE FROM mysql.user WHERE User='';
-- Disallow root login remotely
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
-- Remove test database and access to it
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
-- Reload privilege tables now
FLUSH PRIVILEGES;
EOF
  EOH
  only_if do
    install_type == 'server' &&
    !File.exists?('/root/.chef/.mysql_secure_installation_complete')
  end
end

bash 'setup_mysql_daily_backup' do
  code <<-EOH
    mysql -uroot <<EOF && touch /root/.chef/.setup_mysql_daily_backup_complete
GRANT LOCK TABLES, SELECT, RELOAD ON *.* TO 'backup'@'localhost';
EOF
  EOH
  only_if do
    install_type == 'server' &&
    !File.exists?('/root/.chef/.setup_mysql_daily_backup_complete')
  end
end

template '/usr/local/sbin/backup_mysql_db.sh' do
  source 'backup_mysql_db.sh.erb'
  mode 0755
  owner "root"
  group "root"
  variables(
    :error_mail_recipient => node[:error_mail_recipient],
    :log_base_dir => '/var/log/mysql_backup',
    :dump_base_dir => '/data/mysql_backup',
    :host => Chef::Config[:node_name]
  )
  only_if { install_type == 'server' }
end

template '/etc/cron.d/backup_mysql_db' do
  source 'backup_mysql_db.crontab.erb'
  mode 0644
  owner "root"
  group "root"
  variables(
    :date_and_time_fields => '20 3 * * *'
  )
  only_if { install_type == 'server' }
end

directory '/var/log/old/mysqld' do
  mode 0755
  owner "mysql"
  group "mysql"
  recursive true
  only_if { install_type == 'server' }
end

template '/etc/logrotate.d/mysqld' do
  source 'logrotate-mysqld.erb'
  mode 0644
  owner "root"
  group "root"
  only_if { install_type == 'server' }
end
