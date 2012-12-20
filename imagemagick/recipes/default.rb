#
# Cookbook Name:: imagemagick
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

version = node[:imagemagick][:version]
with_perl = node[:imagemagick][:with_perl]

package "gcc"
package "make"
package "libpng-devel"
package "libjpeg-devel"
package "libtiff-devel"
package "fontconfig-devel"
package "freetype-devel"

remote_file "/usr/local/src/ImageMagick-#{version}.tar.bz2" do
  source "http://www.imagemagick.org/download/ImageMagick-#{version}.tar.bz2"
  case version
  when "6.8.1-0"
    checksum "74e9ec3fa25d6b9206963feedc9b615396aaf68b6726d487dab80308a84a6880"
  when "6.8.0-8"
    checksum "d0a937d764554d88941bb6b98ed210b5397f6a3b294a2842cce07c58fafadcfa"
  end
end

bash "extract-ImageMagick-source" do
  cwd "/usr/local/src"
  code <<-EOH
    tar xf ImageMagick-#{version}.tar.bz2
    cd ImageMagick-#{version}
  EOH
  creates "/usr/local/src/ImageMagick-#{version}"
end

bash "install-ImageMagick" do
  cwd "/usr/local/src/ImageMagick-#{version}"
  code <<-EOH
    ./configure --libdir=/usr/local/lib64 --enable-shared \
      --disable-openmp --without-x \
      --with-png=yes --with-jpeg=yes --with-tiff=yes \
      --with-fontconfig=yes --with-freetype=yes --with-perl=#{with_perl} &&
    make &&
    make install
  EOH
  creates "/usr/local/bin/convert"
end

