#
# Cookbook Name:: passenger
# Recipe:: default
#
# Copyright 2012, Hiroaki Nakamura
#

version = node[:passenger][:version]
gemdir = `gem env gemdir`.chomp

package 'gcc-c++'
package 'make'
package 'httpd-devel'
package 'libcurl-devel'
package 'openssl-devel'
package 'zlib-devel'

gem_package "passenger" do
  version version
end

bash "passenger_module" do
  code <<-EOH
    passenger-install-apache2-module --auto &&
    apxs -ian passenger #{gemdir}/gems/passenger-#{version}/ext/apache2/mod_passenger.so
  EOH
  not_if {
    apache_module_dir = `apxs -q LIBEXECDIR`.chomp
    File.exists? "#{apache_module_dir}/mod_passenger.so"
  }
end

template '/etc/httpd/conf.d/passenger.conf' do
  source 'passenger.conf.erb'
  variables(
    :passenger_root => "#{gemdir}/gems/passenger-#{version}",
    :passenger_ruby => '/usr/local/bin/ruby',
    :passenger_min_instances => 10,
    :passenger_max_pool_size => 30
  )
end
