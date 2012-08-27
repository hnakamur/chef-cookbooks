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

require "#{File.dirname(File.dirname(__FILE__))}/files/default/text_file.rb"

version = node[:nginx][:version]
hostname = `hostname`.chomp

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
  when "1.2.3"
    checksum "06a1153b32b43f100ee9147fe230917deea648f0155111c749e35da120646bf5"
  when "1.2.2"
    checksum "409477c7a9fba58c110a176fd7965b9db188bcf8be0e7f8a0731b8ae1e6ee880"
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

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
  variables(
    :http_port => node[:nginx][:http_port],
    :https_port => node[:nginx][:https_port],
    :crt_file => node[:ssl_certificate][:crt_file],
    :key_file => node[:ssl_certificate][:key_file]
  )
  not_if { FileTest.exists?("/root/.chef/nginx/nginx.conf.written") }
end
directory "/root/.chef/nginx/nginx.conf.written" do
  recursive true
end

template '/etc/nginx/allow_common_ip.conf' do
  source 'allow_common_ip.conf.erb'
  variables(
    :allowed_addresses => node[:nginx][:allowed_addresses]
  )
  not_if { FileTest.exists?("/root/.chef/nginx/allow_common_ip.conf.written") }
end
directory "/root/.chef/nginx/allow_common_ip.conf.written" do
  recursive true
end

directory "/var/www/html/_default/htdocs" do
  owner 'nginx'
  group 'nginx'
  mode 0775
  recursive true
end

cookbook_file "/var/www/html/_default/htdocs/favicon.ico" do
  source "dummy_favicon.ico"
  owner 'nginx'
  group 'nginx'
  mode 0644
  not_if { FileTest.exists?("/var/www/html/_default/htdocs/favicon.ico") }
end

template "/var/www/html/_default/htdocs/index.html" do
  source "index.html.erb"
  owner 'nginx'
  group 'nginx'
  mode 0644
  variables(
    :hostname => hostname
  )
  not_if { FileTest.exists?("/var/www/html/_default/htdocs/index.html") }
end

%w{ vhost.d http.location.d https.location.d }.each do |dir|
  directory "/etc/nginx/#{dir}" do
    owner 'nginx'
    group 'nginx'
    mode 0775
    recursive true
  end
end

directory "/etc/nginx/vhost.d" do
  owner 'nginx'
  group 'nginx'
  mode 0775
  recursive true
end

bash "create_empty_htdigest_passwd_file" do
  code <<-EOH
    touch /var/www/html/.htdigest
  EOH
  not_if { FileTest.exists?("/var/www/html/.htdigest") }
end

bash "create_self_cerficiate" do
  code <<-EOH
    openssl req -new -newkey rsa:2048 -x509 -nodes -set_serial 0 \
    -days #{node[:ssl_certificate][:days]} \
    -subj "#{node[:ssl_certificate][:subject]}" \
    -out #{node[:ssl_certificate][:crt_file]} \
    -keyout #{node[:ssl_certificate][:key_file]} &&
    chmod 400 #{node[:ssl_certificate][:key_file]}
  EOH
  only_if do
    node[:ssl_certificate] &&
    node[:ssl_certificate][:create_self_certificate] &&
    !FileTest.exists?(node[:ssl_certificate][:crt_file])
  end
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

firewall_config_modified = false

ruby_block "edit_firewall_config" do
  file = TextFile.load "/etc/sysconfig/iptables"
  new_lines = [
    "-A INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT",
    "-A INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT"
  ]
  block do
    new_lines.each do |new_line|
      unless file.lines.index new_line
        file.lines.insert(
          file.lines.index(
            "-A INPUT -j REJECT --reject-with icmp-host-prohibited"
          ),
          new_line
        )
      end
    end
    file.save
    firewall_config_modified = true
  end
  not_if do
    file.lines.empty? || new_lines.all?{|new_line| file.lines.index new_line }
  end
end

service "iptables" do
  supports :restart => true
  action [:restart]
  only_if { firewall_config_modified }
end
