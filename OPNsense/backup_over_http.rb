require 'net/http'
require 'openssl'
SERVER_IP = 'your IP'
VERIFY_MODE = OpenSSL::SSL::VERIFY_NONE
#VERIFY_MODE = OpenSSL::SSL::VERIFY_PEER
USERNAME = 'your username'
PASSWORD = 'your password'

indexpage = URI("https://#{SERVER_IP}/index.php")
backuppage = URI("https://#{SERVER_IP}/diag_backup.php")
COOKIES = {}
def dl(uri,method, data)
  Net::HTTP.start(uri.host,
                  uri.port,
                  :use_ssl => uri.scheme == 'https',
                  :verify_mode => VERIFY_MODE) do |http|
    if method == :post
      request = Net::HTTP::Post.new uri
      request['Content-Length'] = data.length
      request.body = data
    else
      request = Net::HTTP::Get.new uri
    end
    request['Cookie'] = COOKIES.keys.map { |k| k + "=" + COOKIES[k] }.join(";")

    response = http.request request
    if '4' == (response.code[0])
      puts request.inspect
      puts response.inspect
      puts response.body
      raise :error
    end
    if response['Set-Cookie']
      cookies = response['Set-Cookie'].split(",").map{|x| x.strip.scan(/([a-zA-Z_]+)=([a-zA-Z0-9]+).*/) }.map(&:first).to_h
      COOKIES.merge! cookies
    end
    response
  end
end
d = dl(indexpage,:get,nil)
csrf_line = d.body.lines.select {|x| x.include? "__opnsense_csrf" }.first
_, token, tokenvalue = csrf_line.scan(/name="([a-z0-9]+)|value="([a-z0-9]+)/i).map {|x| x.first || x.last }


# do login
line = "login=1&passwordfld=#{PASSWORD}&usernamefld=#{USERNAME}&#{token}=#{tokenvalue}"
d = dl(indexpage,:post,line)


line = "donotbackuprrd=on&download=Download&#{token}=#{tokenvalue}"
d = dl(backuppage,:post,line)


File.open("backup_opnsense.xml", "wb") { |f| f.write(d.body) }
