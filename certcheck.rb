#!/usr/bin/env ruby

=begin
Copyright 2019 Fabian Franz

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
THE POSSIBILITY OF SUCH DAMAGE.
=end

require 'net/http'
require 'openssl'
require 'optparse'

host = nil
port = 443
warndays = 7
critdays = 1

OptionParser.new do |parser|
  parser.on("-h", "--host HOSTNAME", "The Hostname to use") do |hn|
    host = hn
  end
  parser.on("-p", "--host PORT", "Port to use") do |po|
    port = po
  end
  parser.on("-c", "--critical CRITICAL", "critical days") do |cr|
    critdays = cr.to_i
  end
  parser.on("-w", "--warning WARNING", "warning days") do |wd|
    warndays = wd.to_i
  end
end.parse!


cert = Net::HTTP.start(host, port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
  http.peer_cert
end
# constant - 1 day
days_left = ((cert.not_after - Time.now) / 86400).to_i


status = 'OK'
code = 0
if days_left < warndays
  status = 'WARNING'
  code = 1
end

if days_left < critdays
  status = 'CRITICAL'
  code = 2
end

puts "#{status} - The certificate is #{days_left} days valid."

exit code


