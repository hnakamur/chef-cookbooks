#
# Cookbook Name:: passenger
# Recipe:: default
#
# Copyright 2012, Hiroaki Nakamura
#

version = node[:passenger][:version]
apache_module_dir = `apxs -q LIBEXECDIR`.chomp

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
    apxs -ian passenger_module `gem env gemdir`/gems/passenger-#{version}/ext/apache2/mod_passenger.so
  EOH
  not_if { File.exists? "#{apache_module_dir}/mod_passenger.so" }
end
