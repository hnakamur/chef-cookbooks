#
# Cookbook Name:: redmine
# Recipe:: default
#
# Copyright 2012, Hiroaki Nakamura
#

version = node[:redmine][:version]
ruby_path = node[:ruby][:path]
session_secret = node[:redmine][:session_secret] || SecureRandom.hex(16)
install_dir = node[:redmine][:install_dir]
install_base_dir = File.dirname(install_dir)
database_name = 'redmine'
tarball_cache = "#{Chef::Config[:file_cache_path]}/redmine-#{version}.tar.gz"
webserver_type = node[:webserver_type]
webserver_user = node[:webserver_user]

package 'mysql-devel'
package 'ImageMagick-devel'

if version.to_f >= 1.4
  gem_package 'bundler'
else
  gem_package 'rack' do
    version '1.1.1'
  end
  gem_package 'rake' do
    version '0.8.7'
  end
  gem_package 'i18n' do
    version '0.4.2'
  end
  gem_package 'mysql' do
    version '2.8.1'
  end
  gem_package 'rails' do
    version '2.3.14'
  end
  gem_package 'coderay' do
    version '1.0.4'
  end
  gem_package 'rw_fastercsv' do
    version '1.5.7'
  end
end

remote_file tarball_cache do
  source "http://rubyforge.org/frs/download.php/76134/redmine-#{version}.tar.gz"
  not_if { File.exists? tarball_cache }
end

directory install_base_dir do
  owner webserver_user
  group webserver_user
  action :create
end

bash 'install_redmine' do
  cwd install_base_dir
  code <<-EOH
    tar xf #{Chef::Config[:file_cache_path]}/redmine-#{version}.tar.gz &&
    cd #{install_dir} &&
    cat <<EOF | patch -p0 &&
--- app/controllers/application_controller.rb.orig      2012-04-14 17:21:00.000000000 +0900
+++ app/controllers/application_controller.rb   2012-04-18 10:09:22.596805018 +0900
@@ -70,6 +70,9 @@
     if session[:user_id]
       # existing session
       (User.active.find(session[:user_id]) rescue nil)
+    elsif (forwarded_user = request.env["REMOTE_USER"])
+      # web server authentication
+      (User.find_by_login(forwarded_user) rescue nil)
     elsif cookies[:autologin] && Setting.autologin?
       # auto-login feature starts a new session
       user = User.try_to_autologin(cookies[:autologin])
EOF
    chown -R #{webserver_user}:#{webserver_user} #{install_dir}
  EOH
  not_if { File.exists? "#{install_dir}/config/database.yml" }
end

template "#{install_dir}/config/database.yml" do
  source "database.yml.erb"
  mode 0666
  owner webserver_user
  group webserver_user
  not_if { File.exists? "#{install_dir}/config/database.yml" }
end

bash 'install_bundles' do
  cwd install_dir
  code <<-EOH
    bundle install --without development test postgresql sqlite
  EOH
  only_if { version.to_f >= 1.4 }
end

if version.to_f <= 1.4
  template "#{install_dir}/config/additional_environment.rb" do
    source "additional_environment.rb.erb"
    mode 0400
    owner webserver_user
    group webserver_user
    variables(
      :session_secret => session_secret
    )
    not_if { File.exists? "#{install_dir}/config/additional_environment.rb" }
  end
end

link "/var/www/html/redmine" do
  to "#{install_dir}/public" 
end

class Chef::Resource::Bash
  include Mysql
end

if version.to_f >= 2.0
  session_create_task = "generate_secret_token"
else
  session_create_task = "generate_session_store"
end
bash 'setup_redmine_database' do
  code <<-EOH
    mysql -uroot <<EOF &&
CREATE DATABASE #{database_name}
DEFAULT CHARACTER SET utf8
DEFAULT COLLATE utf8_general_ci;
EOF
    cd #{install_dir} &&
    rake #{session_create_task} &&
    RAILS_ENV=production rake db:migrate
  EOH
  not_if { has_database? database_name }
end

if webserver_type == 'apache'
  package 'mod_ssl'
  template '/etc/httpd/conf.d/redmine.conf' do
    source 'redmine.conf.erb'
    mode 0666
    owner webserver_user
    group webserver_user
    variables(
      :ruby_path => ruby_path
    )
  end
end
