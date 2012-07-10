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
  case version
  when "1.2.1"
    checksum "994ad97cbf6f7045f95ea9d6d401aad1e95766671e402c48af85aba5235a2dd7"
  end
end

bash 'fetch_nginx_http_auth_digest' do
  cwd '/usr/local/src/'
  code <<-EOH
    git clone https://github.com/samizdatco/nginx-http-auth-digest.git
  EOH
  not_if { FileTest.exists?("/usr/local/src/nginx-http-auth-digest") }
end

bash 'fetch_nginx_tcp_proxy_module' do
  cwd '/usr/local/src/'
  code <<-EOH
    git clone https://github.com/yaoweibin/nginx_tcp_proxy_module.git
  EOH
  not_if { FileTest.exists?("/usr/local/src/nginx_tcp_proxy_module") }
end

bash 'install_nginx' do
  cwd '/usr/local/src/'
  code <<-EOH
    tar xf nginx-#{version}.tar.gz &&
    cd nginx-#{version} &&
    patch -p1 < /usr/local/src/nginx_tcp_proxy_module/tcp.patch &&
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
      --add-module=/usr/local/src/nginx_tcp_proxy_module \
      --add-module=/usr/local/src/nginx-http-auth-digest \
      --with-cc-opt='-O2 -g' &&
    make &&
    make install
  EOH
  not_if { FileTest.exists?("/usr/sbin/nginx") }
end

directory '/var/log/old/nginx' do
  mode 0755
  owner "nginx"
  group "nginx"
  recursive true
end

template '/etc/logrotate.d/nginx' do
  source 'logrotate-nginx.erb'
  mode 0644
  owner "root"
  group "root"
end

%w{ client_temp fastcgi_temp proxy_temp scgi_temp uwsgi_temp }.each do |dir|
  directory "/var/cache/nginx/#{dir}" do
    owner 'nginx'
    group 'root'
    mode 0700
    recursive true
  end
end

template '/etc/init.d/nginx' do
  source 'nginx.erb'
  owner 'root'
  group 'root'
  mode '755'
end

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  not_if { FileTest.exists?("/root/.chef/nginx/nginx.conf.written") }
end

directory "/root/.chef/nginx/nginx.conf.written" do
  recursive true
end

service "nginx" do
  supports :restart => true, :reload => true
  action [:enable, :start]
end
