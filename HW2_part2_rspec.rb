require 'rubygems'
require 'nokogiri'
require 'open-uri'
require_relative 'HW2_part2'
require 'rspec'
require 'rspec/autorun'
require 'rspec/core'
require 'webmock/rspec'
require 'vcr'

# WebMock.allow_net_connect!
VCR.configure do |c|
  c.cassette_library_dir = 'cassettes'
  c.hook_into :webmock
end

RSpec.describe Country do

  before do
    VCR.use_cassette('canada') do
      @uri = 'https://www.cia.gov/library/publications/the-world-factbook/geos/countrytemplate_ca.html'
      @canada = Country.new(@uri, 'Canada')
    end
  end

  describe "#==" do
    it "should regard two countries as the same one only if the class and URI are the same" do
      VCR.use_cassette('canada') do
        @ca = Country.new(@uri, 'ca')
      end
      expect(@ca == @canada).to be true
    end

  end
end