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

package 'mysql-server'

template '/etc/my.cnf' do
  source 'my.cnf.erb'
  variables(
    :expire_logs_days => node[:mysql][:expire_logs_days]
  )
end

service 'mysqld' do
  supports :restart => true
  action [:enable, :start]
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
  not_if { File.exists? '/root/.chef/.mysql_secure_installation_complete' }
end

bash 'setup_mysql_daily_backup' do
  code <<-EOH
    mysql -uroot <<EOF || exit 1
GRANT LOCK TABLES, SELECT, RELOAD ON *.* TO 'backup'@'localhost';
EOF
  EOH
  not_if { File.exists? '/root/.chef/.setup_mysql_daily_backup_complete' }
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
end

template '/etc/cron.d/backup_mysql_db' do
  source 'backup_mysql_db.crontab.erb'
  mode 0644
  owner "root"
  group "root"
  variables(
    :date_and_time_fields => '20 3 * * *'
  )
end
