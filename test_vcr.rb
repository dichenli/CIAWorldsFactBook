require 'net/http'
require 'test_rspec'
require 'rspec/core'
require 'rspec/autorun'
require 'spec_helper'
require 'webmock/rspec'
require 'vcr'
WebMock.allow_net_connect!

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
end

RSpec.configure do |c|
  # so we can use :vcr rather than :vcr => true;
  # in RSpec 3 this will no longer be necessary.
  c.treat_symbols_as_metadata_keys_with_true_values = true
end

start_sinatra_app(:port => 7777) do
  get('/') { "Hello" }
end

def make_http_request
  Net::HTTP.get_response('localhost', '/', 7777).body
end

describe "VCR example group metadata", :vcr do
  it 'records an http request' do
    make_http_request.should == 'Hello'
  end

  it 'records another http request' do
    make_http_request.should == 'Hello'
  end

  context 'in a nested example group' do
    it 'records another one' do
      make_http_request.should == 'Hello'
    end
  end
end

describe "VCR example metadata", :vcr do
  it 'records an http request' do
    make_http_request.should == 'Hello'
  end
end