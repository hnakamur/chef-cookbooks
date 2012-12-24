#
# Cookbook Name:: self_signed_certificate
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

strength = node.ssl_certificate.strength
serial = node.ssl_certificate.serial
days = node.ssl_certificate.days
subject = node.ssl_certificate.subject
crt_file = node.ssl_certificate.crt_file
key_file = node.ssl_certificate.key_file
crt_and_key_file = node.ssl_certificate.crt_and_key_file

bash "create_self_signed_cerficiate" do
  code <<-EOH
    openssl req -new -newkey rsa:#{strength} -sha1 -x509 -nodes \
      -set_serial #{serial} \
      -days #{days} \
      -subj "#{subject}" \
      -out "#{crt_file}" \
      -keyout "#{key_file}" &&
    cat "#{crt_file}" "#{key_file}" >> "#{crt_and_key_file}" &&
    chmod 400 "#{key_file}" "#{crt_and_key_file}"
  EOH
  creates crt_and_key_file
end
