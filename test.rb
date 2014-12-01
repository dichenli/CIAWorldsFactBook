# require 'net/http'
# require 'webmock'
# require 'webmock/rspec'
# include WebMock::API
# WebMock.allow_net_connect!
#
# stub_request(:post, "http://www.example.com/").
#     with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
#     to_return(:status => 200, :body => "aaa", :headers => {content_length: 2})
# # uri = URI.parse("http://www.example.com/")
# # puts uri.port, uri.path
# #puts Net::HTTP.get("www.example.com", "/")
#
# uri = URI.parse("http://www.example.com/")
# req = Net::HTTP::Get.new(uri.path)
# # req['Content-Length'] = 2
#
# res = Net::HTTP.start(uri.host, uri.port) do |http|
#   http.request(req)
#   WebMock.disable_net_connect!
#   http.request(req)
# end    # ===> Success
# puts req.body
# puts res.body

a = "volcanism: the vast majority of volcanoes in Western Canada's Coast Mountains remain dormant"
puts a.include?("volcano")