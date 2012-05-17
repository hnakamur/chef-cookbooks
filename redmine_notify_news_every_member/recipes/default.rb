#
# Cookbook Name:: redmine_notify_news_every_member
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

install_dir = node[:redmine][:install_dir]

bash "install_redmine_notify_news_every_member" do
  code <<-EOH
    cd "#{install_dir}/vendor/plugins" &&
    git clone https://github.com/hiroponz/redmine_notify_news_every_member.git
    cd "#{install_dir}" &&
    rake db:migrate_plugins RAILS_ENV=production &&
    /etc/init.d/httpd graceful
  EOH
  not_if {FileTest.directory? "#{install_dir}/vendor/plugins/redmine_notify_news_every_member"}
end
