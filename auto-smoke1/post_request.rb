require 'uri'
require 'net/https'
require "base64"

class PostRequest

  def initialize(arg)
    @user_name = arg[0]
    @password = arg[1]
    @url = URI.parse(arg[2])
    @data = arg[3]
  end


  # using this to command to run ruby rest_api_script/post_request #{username} #{password} #{url} #{xml data}
  def post_request
    http = Net::HTTP.new(@url.host, @url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Post.new("#{@url}")
    request["content-type"] = 'application/xml'
    request["authorization"] = encode_credentials
    request.body = @data
    response = http.request(request)
    puts response.read_body
  end

  def encode_credentials
    "Basic #{::Base64.strict_encode64("#{@user_name}:#{@password}")}"
  end
end

post_req = PostRequest.new(ARGV)
post_req.post_request