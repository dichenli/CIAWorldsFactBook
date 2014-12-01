require 'rubygems'

require 'simplecov'
SimpleCov.start

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
      @ca_uri = 'https://www.cia.gov/library/publications/the-world-factbook/geos/countrytemplate_ca.html'
      @canada = Country.new(@ca_uri, 'Canada')
    end

    VCR.use_cassette('angola') do
      @ao_uri = 'https://www.cia.gov/library/publications/the-world-factbook/geos/countrytemplate_ao.html'
      @angola = Country.new(@ao_uri, 'Angola')
    end

    VCR.use_cassette('akrotiri') do
      @ax_uri = 'https://www.cia.gov/library/publications/the-world-factbook/geos/countrytemplate_ax.html'
      @akrotiri = Country.new(@ax_uri, 'Akrotiri')
    end

  end

  describe "#==" do
    it "should regard two countries as the same one only if the class and URI are the same" do
      VCR.use_cassette('canada') do
        @ca = Country.new(@ca_uri, 'ca')
      end
      expect(@ca == @canada).to be true
      expect(@canada == @angola).to be false
    end
  end

  describe "#get_all_info, #retrieve_info, #category_match, #assign_value" do
    it "should record all useful information about this country from what's parsed online" do
      @canada.get_all_info
      expect(@canada.continent).to eq("north america")
      expect(@canada.coastline).to eq(202080)
      expect(@angola.population).to eq(18565269)
      expect(@akrotiri.resource).to be_nil
    end
  end

  describe "#find_location" do
    it "should find out the correct continent of the country" do
      #the method is already called from initialize
      expect(@canada.continent).to eq("north america")
      expect(@angola.continent).to eq("africa")
    end
  end

  describe "#find_resource" do
    it "should find out what resources this country have" do
      expect(@canada.resource).to eq("iron ore, nickel, zinc, copper, gold, lead, rare earth elements, molybdenum, potash, diamonds, silver, fish, timber, wildlife, coal, petroleum, natural gas, hydropower")
      expect(@angola.resource).to eq("petroleum, diamonds, iron ore, phosphates, copper, feldspar, gold, bauxite, uranium")
      #akrotiri has no resource entry at all
      expect(@akrotiri.resource).to be nil
    end
  end

  describe "#find_hazards" do
    it "will find what hazards a country have and store results in a list" do
      expect(@canada.hazards).to match_array(["cyclone", "storm"])
      expect(@angola.hazards).to match_array(["flood"])
      expect(@akrotiri.hazards).to match_array([])
    end
  end

  describe "#find_coordinate" do
    it "will find the coordinate of the country" do
      expect(@canada.coordinate_sn).to eq(-60.00)
      expect(@canada.coordinate_ew).to eq(-95.00)
      expect(@angola.coordinate_ew).to eq(18.30)
    end
  end

  describe "#find_population" do
    it "will find the population of the country" do
      expect(@canada.population).to eq(34568211)
      expect(@angola.population).to eq(18565269)
      expect(@akrotiri.population).to eq(15700)
    end
  end

  describe "#find_elec_consume" do
    it "will find the electricity consumption of the country" do
      expect(@canada.elec_consume).to eq(504800000000)
      expect(@angola.elec_consume).to eq(3659000000)
      expect(@akrotiri.elec_consume).to eq(nil)
    end
  end

  describe "#find_elev_extreme" do
    it "will find the elevation extreme of the country" do
      expect(@canada.altitude_min).to eq(0)
      expect(@canada.altitude_max).to eq(5959)
      expect(@angola.altitude_min).to eq(0)
    end
  end

  describe "#find_capital" do
    it "will find the capital city name and coordinates of the country" do
      expect(@canada.capital).to eq("Ottawa")
      expect(@canada.cap_coord_sn).to eq(-45.25)
      expect(@canada.cap_coord_ew).to eq(-75.42)
    end
  end

  describe "#find_parties" do
    it "will find the number of parties of the country" do
      expect(@canada.party_count).to eq(5)
      expect(@angola.party_count).to eq(9)
      expect(@akrotiri.party_count).to eq(0)
    end
  end

  describe "#find_religion" do
    it "will find the dominate religion of the country and the percent of population of the religion" do
      expect(@canada.dominate_religion).to eq("Roman Catholic")
      expect(@canada.domi_relig_percent).to eq(42.6)
    end
  end

  describe "#find_coastline" do
    it "will find the length of coastline of the country" do
      expect(@canada.coastline).to eq(202080)
      expect(@angola.coastline).to eq(1600)
      expect(@akrotiri.coastline).to eq(3)
    end
  end

  describe "#find_border_countries" do
    it "will find the number of border countries of the country" do
      expect(@canada.border_countries).to eq(2)
      expect(@angola.border_countries).to eq(5)
      expect(@akrotiri.border_countries).to eq(1)
    end
  end

  describe "#has_resource?" do
    it "should return whether the country has the given resource" do
      expect(@canada.has_resource?("nickel")).to be_truthy
      expect(@canada.has_resource?("phosphates")).to be false
      expect(@angola.has_resource?("phosphates")).to be true
      #akrotiri has no resource entry at all
      expect(@akrotiri.has_resource?("whatever")).to be false
    end
  end

  describe "#in_continent?" do
    it "will tell whether the country is in the query continent" do
      expect(@canada.in_continent?("North America")).to be true
      expect(@canada.in_continent?("America")).to be true
      expect(@canada.in_continent?("South America")).to be false
      expect(@akrotiri.in_continent?("Europe")).to be true
    end
  end

  describe "#has_hazard?" do
    it "will tell whether the country has the queried hazard" do
      expect(@canada.has_hazard?("storm")).to be true
      expect(@canada.has_hazard?("flood")).to be false
      expect(@canada.has_hazard?("")).to be false
    end
  end

  describe "#elec_consume_per_capita" do
    it "tells the electricity consumption per capita of the country" do
      expect(@canada.elec_consume_per_capita).to be_within(1).of(14603)
      expect(@angola.elec_consume_per_capita).to be_within(1).of(197)
      expect(@akrotiri.elec_consume_per_capita).to be nil
    end
  end

end

#WFB is not initialized in "before" action 
# because it's too slow for initialization and WFB don't really get modified during the run
VCR.use_cassette('worldsFactBook') do
  WFB = WorldsFactBook.new
end

RSpec.describe WorldsFactBook do

  describe "#valid_continent?" do
    it "tells if a given string is a valid continent name" do
      expect(WFB.valid_continent?("North America")).to be true
      expect(WFB.valid_continent?("America")).to be false
      expect(WFB.valid_continent?("")).to be false
      expect(WFB.valid_continent?(:asia)).to be false
    end
  end

  describe "#list_geohazard_countries" do
    it "lists all countries within a continent that has the given geohazard" do
      result =["Afghanistan", "Brunei",
                "Burma", "Cambodia",
                "China", "Egypt",
                "India", "Indonesia",
                "Iran",
                "Iraq",
                "Korea, North",
                "Korea, South",
                "Laos",
                "Malaysia",
                "Nepal",
                "Pakistan",
                "Russia",
                "Tajikistan",
                "Timor-Leste",
                "Vietnam"]
      expect(WFB.list_geohazard_countries("Asia", "flood")).to match_array(result)

      expect(WFB.list_geohazard_countries("aaa", "flood")).to be nil
      expect(WFB.list_geohazard_countries("Asia", "bbb")).to be nil
    end
  end

  describe "#lowest_point_country" do
    it "lists the country with the lowest altitude point of a given continent" do
      expect(WFB.lowest_point_country("asia")).to eq("Israel")
      expect(WFB.lowest_point_country("aaa")).to be nil
    end
  end

  describe "#countries_hemisphere" do
    it "lists all countries in a given hemisphere" do
      result = ["Angola",
                "Ashmore and Cartier Islands",
                "Australia",
                "Botswana",
                "Bouvet Island",
                "British Indian Ocean Territory",
                "Burundi",
                "Christmas Island",
                "Cocos (Keeling) Islands",
                "Comoros",
                "Congo, Democratic Republic of the",
                "Congo, Republic of the",
                "Coral Sea Islands",
                "Fiji",
                "French Southern and Antarctic Lands",
                "Gabon",
                "Heard Island and McDonald Islands",
                "Indonesia",
                "Lesotho",
                "Madagascar",
                "Malawi",
                "Mauritius",
                "Mozambique",
                "Namibia",
                "Nauru",
                "New Caledonia",
                "New Zealand",
                "Norfolk Island",
                "Papua New Guinea",
                "Rwanda",
                "Seychelles",
                "Solomon Islands",
                "South Africa",
                "Swaziland",
                "Tanzania",
                "Timor-Leste",
                "Tuvalu",
                "Vanuatu",
                "Zambia",
                "Zimbabwe"]
      expect(WFB.countries_hemisphere("southeastern")).to match_array(result)
      expect(WFB.countries_hemisphere("aaa")).to be nil
    end
  end

  describe "#continent_parties_num" do
    it "finds out the countries in the given continent with more than #num of parties" do
      result = ["Australia", "Fiji", "New Caledonia", "New Zealand", "Papua New Guinea", "Solomon Islands", "Tonga", "Vanuatu", "Wallis and Futuna"]
      expect(WFB.continent_parties_num("oceania", 5)).to match_array(result)
      expect(WFB.continent_parties_num("aaa", 5)).to match_array([])
      expect(WFB.continent_parties_num("asia", 100)).to match_array([])
    end
  end

  describe "#elec_consume_rank" do
    it "returns the top #num countries in the world with highest electricity consumption per capita" do
      result = ["Iceland", "Norway", "Kuwait"]
      expected = WFB.elec_consume_rank(3).map{|country| country.name}
      expect(expected).to match_array(result)
      expect(WFB.elec_consume_rank(0)).to be nil
    end
  end

  describe "#religion_percent" do
    it "#finds countries of which dominate religion accounts for more than %percent of population" do
      result = ["Algeria",
                "Gaza Strip",
                "Morocco",
                "Saint Pierre and Miquelon",
                "Turkey",
                "Wallis and Futuna"]
      expect(WFB.religion_percent(">99%").map{|country| country.name}).to match_array(result)

      result = ["China", "Russia", "Vietnam"]
      expect(WFB.religion_percent("<10%").map{|country| country.name}).to match_array(result)

      expect(WFB.religion_percent("10%")).to be nil
    end
  end

  describe "#coastline_rank" do
    it "tells the rank of a given country's coastline length among all countries" do
      expect(WFB.coastline_rank("China")).to eq(11)
      expect(WFB.coastline_rank("aaaa")).to be nil
      expect(WFB.coastline_rank(:China)).to be nil
    end
  end

  describe "#country_resource" do
    it "#finds all countries with the given kind of resource (as a string)" do
      result = ["Algeria", "Angola",
                "Brazil", "Burkina Faso",
                "Cambodia", "Congo, Republic of the",
                "Curacao",
                "Egypt",
                "Guinea-Bissau",
                "Iraq",
                "Jordan",
                "Mali",
                "Mongolia",
                "Morocco",
                "Nauru",
                "Niger",
                "Senegal",
                "Solomon Islands",
                "South Africa",
                "Sri Lanka",
                "Syria",
                "Tanzania",
                "Togo",
                "Tunisia",
                "United States",
                "Vietnam",
                "Western Sahara"]
      expect(WFB.country_resource("phosphates")).to match_array(result)
      expect(WFB.country_resource("aaa")).to match_array([])
      expect(WFB.country_resource(:phosphates)).to be nil
    end
  end

  describe "#landlocked_single_neighbor" do
    it "finds out whether the country is landlocked or not" do
      result = ["Holy See (Vatican City)", "Lesotho", "San Marino"]
      expect(WFB.landlocked_single_neighbor).to match_array(result)
    end
  end

  describe "#find_most_capital_block" do
    it "finds out the position of a square block on the earth of given size
        that contains the most number of capital cities" do
      expect(WFB.find_most_capital_block(2)[1]).to eq("20 0 N")
      expect(WFB.find_most_capital_block(2)[3]).to eq("65 0 W")
      expect(WFB.find_most_capital_block(0)).to be nil
    end
  end

  describe "#convert_coord" do
    it "converts a given index to a string showing latitude or longitude" do
      expect(WFB.convert_coord(-20, "longitude")).to eq("200 0 W")
      expect(WFB.convert_coord(20, "latitude")).to eq("70 0 N")
      expect(WFB.convert_coord(20, "aaaa")).to eq("")
    end
  end
end