#
# Cookbook Name:: nginx
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

version = node[:nginx][:version]

bash "exclude_nginx_in_nginx" do
  code <<-'EOH'
    TMPFILE=/tmp/epel.repo.$$ &&
    awk '
/^\[epel\]$/,/^$/{
  if (/^$/) print "exclude=node*"
  print $0
  next
}
{print $0}
' /etc/yum.repos.d/epel.repo > $TMPFILE &&
    cp $TMPFILE /etc/yum.repos.d/epel.repo
  EOH
  not_if "grep -q '^exclude=node\*' /etc/yum.repos.d/epel.repo"
end

%w{ make gcc openssl-devel zlib-devel libxslt-devel gd-devel GeoIP-devel }.each do |pkg|
  package pkg
end

group 'nginx' do
  gid node[:nginx][:gid]
end

user 'nginx' do
  uid node[:nginx][:uid]
  gid 'nginx'
  home '/var/lib/nginx'
  shell '/bin/nologin'
  comment 'Nginx web server'
end

remote_file "/usr/local/src/nginx-#{version}.tar.gz" do
  source "http://nginx.org/download/nginx-#{version}.tar.gz"
end

bash 'install_nginx' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf nginx-#{version}.tar.gz &&
    cd nginx-#{version} &&
    ./configure --prefix=/usr/local/nginx-#{version} \
      --sbin-path=/usr/sbin/nginx \
      --conf-path=/etc/nginx/nginx.conf \
      --error-log-path=/var/log/nginx/error.log \
      --http-log-path=/var/log/nginx/access.log \
      --pid-path=/var/run/nginx.pid \
      --lock-path=/var/run/nginx.lock \
      --http-client-body-temp-path=/var/cache/nginx/client_temp \
      --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
      --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
      --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
      --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
      --user=nginx \
      --group=nginx \
      --with-file-aio \
      --with-ipv6 \
      --with-http_ssl_module \
      --with-http_realip_module \
      --with-http_addition_module \
      --with-http_xslt_module \
      --with-http_image_filter_module \
      --with-http_geoip_module \
      --with-http_sub_module \
      --with-http_dav_module \
      --with-http_flv_module \
      --with-http_mp4_module \
      --with-http_gzip_static_module \
      --with-http_random_index_module \
      --with-http_secure_link_module \
      --with-http_degradation_module \
      --with-http_stub_status_module \
      --with-mail \
      --with-mail_ssl_module \
      --with-pcre-jit \
      --with-md5-asm \
      --with-sha1-asm \
      --with-cc-opt='-O2 -g' &&
    make &&
    make install
  EOH
  not_if { FileTest.exists?("/usr/sbin/nginx") }
end

template '/etc/init.d/nginx' do
  source 'nginx.erb'
  owner 'root'
  group 'root'
  mode '755'
end

service "nginx" do
  supports :restart => true, :reload => true
  action [:enable, :start]
end
