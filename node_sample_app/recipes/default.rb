#
# Cookbook Name:: node_sample_app
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

vhost = node[:node_sample_app][:vhost]
port = node[:node_sample_app][:port]

topdir = "/var/www/html/#{vhost}"
appdir = "/var/www/html/#{vhost}/app"
logdir = "/var/www/html/#{vhost}/logs"

directory logdir do
  mode "0777"
  owner "root"
  group "root"
end

bash "extract_node_sample_app_files" do
  cwd topdir
  code <<-EOH
    tar xf #{File.dirname(File.dirname(__FILE__))}/files/default/node_sample_app_files.tar.bz2
  EOH
  not_if { FileTest.exist?(appdir) }
end

template "#{appdir}/app.js" do
  source "app.js.erb"
  mode "0644"
  owner "root"
  group "root"
  variables(
    :port => port
  )
  not_if { FileTest.exist?("#{appdir}/app.js") }
end

template "#{appdir}/views/index.ejs" do
  source "index.ejs.erb"
  mode "0644"
  owner "root"
  group "root"
  variables(
    :vhost => vhost,
    :port => port
  )
  not_if { FileTest.exist?("#{appdir}/views/index.ejs") }
end
