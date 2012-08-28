#
# Cookbook Name:: postgresql
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

install_type = node[:postgresql][:install_type]
version = node[:postgresql][:version]
repo_rpm_url = node[:postgresql][:repo_rpm_url]

ver = version.sub(/\./, '')

bash 'install_postgresql_repository' do
  code <<-EOH
    rpm -ivh #{repo_rpm_url}
  EOH
  not_if "rpm -q --quiet pgdg-centos#{ver}"
end

if install_type == 'client'

  %w{ libs devel }.each do |pkg|
    package "postgresql#{ver}-#{pkg}"
  end

else

  %w{ server devel }.each do |pkg|
    package "postgresql#{ver}-#{pkg}"
  end

  service_name = "postgresql-#{version}"

  bash 'init_postgresql_db' do
    code <<-EOH
      service #{service_name} initdb
    EOH
    not_if { FileTest.exist?("/var/lib/pgsql") }
  end

  template "/var/lib/pgsql/#{version}/data/pg_hba.conf" do
    source 'pg_hba.conf.erb'
    owner 'postgres'
    group 'postgres'
    mode '0400'
    variables(
      :auth_lines => node[:postgresql][:auth_lines]
    )
    not_if { FileTest.exists?("/root/.chef/postgresql/pg_hba.conf.written") }
  end
  directory "/root/.chef/postgresql/pg_hba.conf.written" do
    recursive true
  end

  service service_name do
    supports :restart => true
    action [:enable, :start]
  end
end
