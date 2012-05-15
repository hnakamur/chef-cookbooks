#
# Cookbook Name:: redmine
# Recipe:: default
#
# Copyright 2012, Hiroaki Nakamura
#

version = node[:redmine][:version]
install_base_dir = '/var/www'
install_dir = "#{install_base_dir}/redmine-#{version}"
database_name = 'redmine'
tarball_cache = "#{Chef::Config[:file_cache_path]}/redmine-#{version}.tar.gz"
cookbook_dir = File.dirname(File.dirname(__FILE__))

package 'mysql-devel'

remote_file tarball_cache do
  source "http://rubyforge.org/frs/download.php/76013/redmine-#{version}.tar.gz"
  not_if { File.exists? tarball_cache }
end

bash 'install_redmine' do
  cwd install_base_dir
  code <<-EOH
    tar xf #{Chef::Config[:file_cache_path]}/redmine-#{version}.tar.gz &&
    cd #{install_dir} &&
    cp config/database.yml.example config/database.yml &&
    patch -p0 < #{cookbook_dir}/files/default/webserver_auth.patch &&
    patch -p0 < #{cookbook_dir}/files/default/env_session.patch &&
    chown -R apache:apache #{install_dir}
  EOH
  not_if { File.exists? "#{install_dir}/config/database.yml" }
end

link "/var/www/html/redmine" do
  to "#{install_dir}/public" 
end

class Chef::Resource::Bash
  include Mysql
end

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

bash 'setup_redmine_database' do
  code <<-EOH
    mysql -uroot <<EOF &&
CREATE DATABASE #{database_name}
DEFAULT CHARACTER SET utf8
DEFAULT COLLATE utf8_general_ci;
EOF
    cd #{install_dir} &&
    rake generate_session_store &&
    rake db:migrate RAILS_ENV=production
  EOH
  not_if { has_database? database_name }
end

template '/etc/httpd/conf.d/redmine.conf' do
  source 'redmine.conf.erb'
end
