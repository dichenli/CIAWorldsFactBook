require 'rubygems'
require 'nokogiri'
require 'open-uri'

class Country
  attr_reader :name, :continent, :region, :hazards, :coordinate_ew, :coordinate_sn,
              :coordinate_sn, :population, :elec_consume, :altitude_min, :altitude_max,
              :capital, :cap_coord_ew, :cap_coord_sn, :party_count, :dominate_religion,
              :landlocked, :border_countries, :uri, :elec_per_capita, :domi_relig_percent,
              :coastline, :resource

  QUERY_HASH = {:"location" => "Location:",
                :"hazards" =>"Natural hazards:",
                :"coordinates" => "Geographic coordinates:",
                :"population" => "Population:",
                :"electricity consumption" => "Electricity - consumption:",
                :"lowest point" => "Elevation extremes:",
                :"highest point" => "Elevation extremes:",
                :"parties" => "Political parties and leaders:",
                :"religions" => "Religions:",
                :"capital"=> "Capital:",
                :"landlocked" => "Coastline:",
                :"border countries" => "Land boundaries:",
                :"natural recources" => "Natural resources:"}

  ASIA = ["Asia", "archipelago in the Indian Ocean", "islands in the Indian Ocean", "middle east", "Middle East"]
  AFRICA = ["Africa","island in the South Atlantic Ocean"]
  EUROPE = ["Europe", "Eastern Mediterranean"]
  NORTH_AMERICA = ["North America", "Northern America", "Caribbean", "Central America",
                     "chain of islands in the North Atlantic Ocean", "Middle America",
                     "two island groups in the North Atlantic Ocean"]
  SOUTH_AMERICA = ["South America"]
  OCEANIA = ["Oceania"]
  CONTINENTS_HASH = {ASIA => "asia", AFRICA => "africa", EUROPE => "europe",
                       NORTH_AMERICA => "north america", SOUTH_AMERICA => "south america", OCEANIA => "oceania"}
  #Regions to continents mapping

  HAZARD_LIST = { :"earthquake" => "earthquake",
                  :"flood" => "flood",
                  :"drought" => "drought",
                  :"tsunam" => "tsunami",
                  :"mudslid" => "mudslide",
                  :"typhoon" => "typhoon",
                  :"avalanch" => "avalanche",
                  :"storm" => "storm",
                  :"hurrican" => "hurricane",
                  :"windstorm" => "windstorm",
                  :"cyclon" => "cyclone",
                  :"forest fire" => "forest fire",
                  :"maritime hazard" => "maritime hazard",
                  :"harmattan" => "harmattan",
                  :"monsoonal rain" => "monsoon rain", :"monsoon rain" => "monsoon rain",
                  :"volcano" => "volcano", :"volcani" => "volcano"}

  def initialize(coun_uri, name)
    @name = name #country name
    @continent = nil  #asia, europe, pacific ocean, Africa, North America, south America
    @region = nil #south asia, middle east, Carribean
    @hazards = [] #earthquakes, etc
    @coordinate_ew = nil #a float number. E: positive, W: negative
    @coordinate_sn = nil # a float number. North: positive, S: negative
    @population = nil
    @elec_consume = nil#electricity consumption
    @altitude_min = nil #lowest point of country
    @altitude_max = nil #highest point
    @capital = nil #capital name
    @cap_coord_ew = nil #capital coordinate
    @cap_coord_sn = nil
    @party_count  = 0#number of political parties
    @dominate_religion = nil
    @domi_relig_percent = nil #dominate religion % of people
    @landlocked = nil #True if the country is landlocked
    @border_countries = nil  #number of  boundary countries
    @elec_per_capita = nil #electricity consumption per capita
    @coastline = nil #the total length of coastline
    @resource = nil #natural resources of a country
    @uri = coun_uri  #uri to the country page
    @noko_page = nil #nokogiri page object of the country page
    @noko_info = nil #information from nokogiri page match

    #query_hash maps keys, which are queries from users, to values,
    # which are the relative information titles on the page

   

    @noko_page = Nokogiri::HTML(open(@uri))
    @noko_info = @noko_page.css("div").select{|entry| entry["class"] =~ /category.*/}
    #all useful pieces of information are stored in <div> with class="category" or "category_data"
    get_all_info
    #get all info about a country at once!
    #puts @name + " done!"
  end

  def ==(country) #define class equal
    country.class == self.class && country.uri == self.uri
  end

  def get_all_info #get all information within the class capability of a country from WFB
    QUERY_HASH.each {|key, value| retrieve_info(key)}
  end

  def retrieve_info(query)
    #get info needed of the country
    #query tells what kind of info you are interested in
    #each piece of info is always between <div> tags, parent category has class="category" and id="field"
    #information has class="category" or "category_data" and id="data"
    return nil if (target = QUERY_HASH[query]) == nil
    flag = nil
    @noko_info.each do |info|
      flag = category_match(target, info) if info["id"] == "field"
      flag = assign_value(info, flag) if flag and info["id"] != "field"
      #the category of each piece of information is right above in the list
      #so we use category to keep track of what info it is in each elem
    end
  end

  def category_match(target, info)
    #match success if info is a "field" and it matches the string in target, which is a value in @query_hash
    return nil if info.class != Nokogiri::XML::Element
    return target if info.text.to_s.strip == target and info["id"] == "field"
    return nil
  end

  def assign_value(info, target)
    #given what target infomation it is, this method is a hash that call necessary methods
    #to assign value to instance variables accordingly
    return nil if info == nil or target == nil
    return find_location(info) if target == "Location:"
    return find_hazards(info) if target == "Natural hazards:"
    return find_coordinate(info, target) if target == "Geographic coordinates:"
    return find_population(info, target) if target == "Population:"
    return find_elec_consume(info, target) if target == "Electricity - consumption:"
    return find_parties(info, target) if target == "Political parties and leaders:"
    return find_religion(info, target) if target == "Religions:"
    return find_coastline(info) if target == "Coastline:"
    return find_border_countries(info, target) if target == "Land boundaries:"
    return find_elev_extreme(info, target) if target == "Elevation extremes:"
    return find_capital(info, target) if target == "Capital:"
    return find_resource(info) if target == "Natural resources:"

    #error if no match
    raise ArgumentError, "exceptions! Not covered in assign value method"
  end

  def find_location(info)
    #find the continent of the country
    #store location description to region as it is
    @region = info.text.strip.downcase
    CONTINENTS_HASH.each do |key, value|
      key.to_a.each do |string|
        if @region.downcase.include?(string.downcase)
          @continent = value
          return nil #set flag to nil so that location info won't be overwritten
        end
      end
    end
  end

  def find_resource(info)
    #find the natural resources information of the country
    #store description to @resource as it is
    @resource = info.text.strip.downcase
    #puts @resource
    return nil
  end

  def find_hazards(info)
    #content is the next info after title
    hazard_text = info.text.strip.downcase
    HAZARD_LIST.each do |key, value|
      if hazard_text.include?(key.to_s) and not @hazards.include?(value)
        @hazards.push(value)
      end
    end
    return nil #info won't be overwritten
  end

  def find_coordinate(info, target)
    #find coordinate of the country
    coord = info.text.strip.match(/(\d+) (\d+) ([NS]), (\d+) (\d+) ([EW])/)
    return target if coord == nil
    @coordinate_sn = Float(coord[1]) + Float(coord[2])/100
    @coordinate_sn *= (-1) if coord[3] == "N"
    @coordinate_ew = Float(coord[4]) + Float(coord[5])/100
    @coordinate_ew *= (-1) if coord[6] == "W"
    #coordinate is positive if it's south or east, negative otherwise
    return nil  #info won't be overwritten
  end

  def find_population(info, target)
    #find out the population of a country
    popstr = info.text.match(/(\d+,)*\d+/)
    return target if popstr == nil
    #if info is not found, try to find it on the next tag
    @population = Integer(popstr[0].delete(','))
    return nil #info won't be overwritten
  end

  def find_elec_consume(info, target)
    elecstr = info.text.match(/(\d*,*\d*,*\d*,*\d*,*\d+\.*\d*)+ *(\w*) kWh/)
    return target if elecstr == nil
    @elec_consume = Float(elecstr[1].delete(','))
    #input could be: 1,111,111.11 billion kWh, we will transfer it to a float number in kWh
    power = {:"trillion" => 1e12, :"billion" => 1e9, :"million" => 1e6, :"thousand" => 1e3, :"" => 1}
    power.each do |key, value|
      @elec_consume *= value if key.to_s == elecstr[2]
    end
    return nil #info won't be overwritten
  end

  def find_elev_extreme(info, target)
    #find the highest and lowest point of a country
    matched = info.text.match(/(-?\d*,*\d+\.*\d*) (k*m)/)
    return target if matched == nil
    altitude = Float(matched[1].delete(','))
    altitude *= 1000 if matched[2] == "km"
    if info.text.include?("highest point")
      @altitude_max = altitude
    elsif info.text.include?("lowest point")
      @altitude_min = altitude
    end
    return target
  end

  def find_capital(info, target)
    coord = nil
    if info.text.include?("coordinates")
      coord = info.text.match(/(\d+) (\d+) ([NS]), (\d+) (\d+) ([EW])/)
    end
    if coord != nil
      @cap_coord_sn = Float(coord[1]) + Float(coord[2])/100
      @cap_coord_sn *= (-1) if coord[3] == "N"
      @cap_coord_ew = Float(coord[4]) + Float(coord[5])/100
      @cap_coord_ew *= (-1) if coord[6] == "W"
      #coordinate is positive if it's south or east, negative otherwise
      return nil
    else
      matched = info.text.strip.match(/name: (.+)/)
      @capital = matched[1].gsub(/; .*| \(.*/, '') unless matched == nil
    end
    return target
  end

  def find_parties(info, target)
    #find out how many parties are in each country
    if info.text.include?("none")
      @party_count = 0 #if it says none, then no party in the country
      return nil #stops counting
    end
    if info.text.include?("parties")
      num = info.text.match(/(\d+) (\w* *\w* *\w* *\w* *)parties/)
      #match number of parties with at most 4 words between the number and the "parties"
      @party_count += Integer(num[1]) if num != nil
    elsif info.text.strip.match("note:")
      #Including "note:" a sign that this is not a party name, so do nothing
    elsif info.text.strip.match("eight nominally independent small parties")
      @party_count += 8 #a special case for China
    else
      info.text.each_char {|c| @party_count += 1 if c == ";"}
      #some countries list all parties in one tag, separate each by ";"
      @party_count += 1
    end
    return target #don't stop counting parties from the following tags
  end

  def find_religion(info, target)
    #find out the dominate religion name and its believer population percentage
    matched = info.text.strip.match(/([a-zA-Z \(\)]+) (\d+\.*\d*)%.+/)
    if matched == nil
      matched = info.text.strip.match(/([a-zA-Z ]+).+/)
      @dominate_religion = matched[1].to_s.strip
    else
      @domi_relig_percent = Float(matched[2])
      @dominate_religion = matched[1].to_s.strip
    end
    return nil if @dominate_religion != nil #stop counting
    return target
  end

  def find_coastline(info)
    #@landlocked = true if the country is landlocked
    #@coastline stores the total length of coastline of the country in km
    if info.text.include?("landlocked")
      @landlocked = true
    else
      @landlocked = false
    end
    match = info.text.strip.match(/(\d*,*\d+) km/) #match with 1,234 km, for example
    unless match == nil
      @coastline = Integer(match[1].delete(','))
    end
    #convert matched data to integer
    return nil
  end

  def find_border_countries(info, target)
    #find out the number of countries sharing border with this country
    if info.text.include?("total:")
      return target
      #under "land boundaries" topic, the total category only tells the total land border length
    else
      matched = info.text.scan(/\d*,*\d+ km/)
      #find how many matches of /\d+ km/, each match indicates one match of border country
      @border_countries = matched.to_a.size
      #matched result convert to array, then the array size indicates border countries number
    end
    return nil if @border_countries != nil
    return target
  end

  def has_resource?(resource_name)
    #return true if the country has the input resource
    return false unless resource_name.class == String and @resource != nil
    #puts @name, resource_name
    #puts @resource.include?(resource_name.downcase)
    return @resource.include?(resource_name.downcase)
  end

  def in_continent?(continent_input)
    #return true if the country is in the corresponding continent
    return false if continent_input.class != String or continent_input.chomp == ""
    retrieve_info("location")
    return false if @continent == nil
    return true if continent_input.downcase.include?(@continent)
    return true if @continent.include?(continent_input.downcase)
    return false
  end

  def has_hazard?(hazard_type)
    #return true if the country has the hazard type
    return false unless hazard_type.class == String and hazard_type.chomp != ""
    retrieve_info("hazards") if @hazards.size == 0
    @hazards.each do |elem|
      return true if hazard_type.downcase.include?(elem.downcase)
      return true if elem.downcase.include?(hazard_type.downcase)
    end #match success if hazard name include hazard element or otherwise
    return false
  end

  def elec_consume_per_capita
    if @elec_consume == nil or @population == nil
      retrieve_info("electricity consumption")
      retrieve_info("population")
    end
    return nil if @elec_consume == nil or @population == nil
    @elec_per_capita = Float(@elec_consume) / Float(@population)
    #find out electricity consumption and population, then divide to find the consumption/capita
    return @elec_per_capita
  end

#end of class
end

class WorldsFactBook

  def initialize
    @non_country = ["oo", "xx", "ee", "ay", "xq", "zh", "zn", "xo"]#except World, several oceans and European Union
    @world_factbook = "https://www.cia.gov/library/publications/the-world-factbook/print/textversion.html"
    @countries = Array.new #@countries is a list of all the Country objects, each element is one country from WFB
    @src = open(@world_factbook)
    @src.read.scan(/<option value="..\/geos\/(.*)\.html"> (.*) <\/option>/) do |country|
      country_uri ="https://www.cia.gov/library/publications/the-world-factbook/geos/countrytemplate_" + country[0] + ".html"
      unless @non_country.include?(country[0])
        @countries.push(Country.new(country_uri, country[1]))
        #create the countries list, for each country we find from WFB, we push it to the list
      end
    end
  end

  def valid_continent?(continent)
    return false unless continent.class == String
    continents = ["asia", "africa", "europe", "north america", "south america", "oceania"]
    return continents.include?(continent.chomp.downcase)
  end

  def list_geohazard_countries(continent, hazard_type)
    #find all countries in one continent that has the given hazard type
    return nil unless valid_continent?(continent)
    hazards = ["earthquake", "flood", "drought", "tsunami", "mudslide", "typhoon", "avalanche", "storm",
               "hurricane", "windstorm", "cyclone", "forest fire", "maritime hazard", "harmattan",
               "monsoonal rain", "monsoon rain", "volcano"]
    hazard_type = hazard_type.chomp.to_s.strip.downcase
    return nil unless hazards.include?(hazard_type)
    count_list = Array.new
    @countries.each do |country|
      if country.in_continent?(continent) and country.has_hazard?(hazard_type)
        count_list.push(country)
      end
    end
    return count_list.map{|country| country.name}
  end

  def lowest_point_country(continent)
    return nil unless valid_continent?(continent)
    #find the country with the lowest elevation point in one continent
    lowest_country = @countries.each{ |country| country.retrieve_info("region") #make sure region info is retrieved
    }.select{|country| country.in_continent?(continent) #find countries in that continent
    }.each{|country| country.retrieve_info("lowest point") #find lowest point of each country
    }.select{|country| country.altitude_min != nil #lowest point info found
    }.min{|country1, country2| country1.altitude_min <=> country2.altitude_min} #find the min of lowest point

    begin
      return lowest_country.name #in case lowest_country == nil or similar cases
    rescue
      return nil
    end
  end

  def countries_hemisphere(hemisphere)
    #direction is one of ["southeastern", "northeastern", "southwestern", "northwestern"]
    #This method lists all countries that are in the given hemisphere
    hemispheres = {"southeastern" => [1, 1], "northeastern" => [-1, 1],
                   "southwestern" => [1, -1], "northwestern" => [-1, -1]}
    match = nil
    hemispheres.each{|key, value| match = value if key.include?(hemisphere.downcase)}
    return nil if match == nil
    in_hemisphere = @countries.select {#select countries which coordinates match the corresponding hemisphere
        |country| country.coordinate_sn * match[0] >= 0 and country.coordinate_ew * match[1] >= 0
    }.map{|country| country.name}
    return in_hemisphere
  end

  def continent_parties_num (continent, num)
    #find out the countries in the given continent with more than #num of parties
    return [] unless valid_continent?(continent)
    return [] unless num.class == Fixnum and num >= 0
    list = @countries.select{|country| country.in_continent?(continent)
    }.select{|country| country.party_count >= num}.map{|country| country.name}
    return list
  end

  def elec_consume_rank(num)
    #return the top #num countries in the world with highest electricity consumption per capita
    return nil unless num.class == Fixnum and num >= 1
    list = @countries.select{|country| country.elec_consume_per_capita != nil
    }.sort{|country1, country2| country2.elec_per_capita <=> country1.elec_per_capita}
    #sort from high to low
    return list if num > list.length
    return list[0...num]
  end

  def religion_percent(percent)
    #find countries of which dominate religion accounts for more than %percent of population
    #argument percent is in form ">or< xx%", such as "> 50%"
    match = percent.match(/([><]) *(\d+\.*\d*) *%/)
    #match[1] is > or < sign, match[2] is a percent number
    return nil if match == nil
    sign = {">" => 1, "<" => -1}
    return nil if sign[match[1]] == nil
    #match[1] is either ">" or "<", so sign[match[1]] is 1 or -1
    num = Float(match[2])
    return nil unless num <= 100 and num >= 0
    # >100% or <0% is not rational
    list = @countries.select{
        |country| country.domi_relig_percent != nil and (country.domi_relig_percent - num) * sign[match[1]] >= 0}
    #select countries whose dominate religion has > num percent
    return list
  end

  def coastline_rank(country_name)
    #given a country name, this method tells the rank of its coastline length among countries
    return nil if country_name.class != String
    matched = nil
    @countries.each do |country|
      if country_name == country.name
        matched = country
        break
      end
    end #given a country name, find out the country object in @countries list
    return nil if matched == nil or matched.coastline == nil
    rank = nil
    @countries.select{|country| country.coastline != nil
    }.sort{|country1, country2| country2.coastline <=> country1.coastline
    }.each_with_index do |country, index|
      #sort from high to low, then find out the index of the country with the same length of coastline
      rank = index + 1
      break if country.coastline <= matched.coastline
    end
    return rank
  end

  def country_resource(resource)
    #find all countries with the given kind of resource (as a string)
    return nil if resource.class != String
    resource = resource.strip.downcase
    return nil if resource == ""
    return @countries.select{|country| country.has_resource?(resource)}.map{|country| country.name}
  end

  def landlocked_single_neighbor
    @countries.select{|country| country.border_countries == 1 and country.landlocked}.map{|country| country.name}
  end

  def find_most_capital_block(dgs)
    #degrees means the degrees extent of the altitude and longitude of a "rectangular" block
    return nil unless dgs.class == Fixnum and dgs <= 180 and dgs >= 1
    #The largest rectangular block possible on earth is 180 * 180 degree
    earth = Array.new(180) { |i| Array.new(360 + dgs - 1) { |i| 0 }}
    #Create a 2D array, for each earth[x][y], x is the latitude + 90, y is the longitude + 180.
    #So south will be 90 to 180, north will be 0 to 90. East will be 180 to 360, West will be 0 to 180
    #Each cell earth[i][j] is a 1 * 1 degree region on earth
    list = @countries.select{|country| country.cap_coord_sn != nil and country.cap_coord_ew != nil}
    list.each{|country| earth[Integer(country.cap_coord_sn + 90)][Integer(country.cap_coord_ew + 180)] += 1}
    #Each cell stores the number of capitals in the 1 * 1 degree region
    earth.each{|row| row.each_index { |index| row[index] = row[index - 360] if index >= 360}}
    #Copy the columns 0 to dgs to columns 360 to 360 + dgs - 1
    earth.each_index{|i| earth[i].each_index{|j|
      for k in (i + 1)..(i + dgs - 1)
        earth[i][j] += earth[k][j]
      end
    } if i <= 180 - dgs}
    #For each given cell in the 2D array, now sum the values of #dgs cells in the same column from this cell
    earth.each_index{|i| earth[i].each_index{|j|earth[i][j] = earth[i][j..(j + dgs - 1)].reduce{|s,n|s + n} if j < 360}}
    #For each given cell in the 2D array, now sum the values of #dgs cells in the same row from this cell
    #After the two steps sums, now each cell should store the # of capitals
    #inside each dgs*dgs size block with the cell as the top left (northwestern) corner
    max = [0, 0] #stores the index i, j of the maximum value cell
    earth.each_index{|i| earth[i].each_index{|j| max = [i, j] if earth[max[0]][max[1]] < earth[i][j] and j < 360} }
    #comparison to find out the i , j of the cell with maxumum value
    list = list.select{|country| country.cap_coord_sn != nil and country.cap_coord_ew != nil}
    list = list.select{ |country| (max[0]..(max[0] + dgs - 1)).cover?(Integer(country.cap_coord_sn + 90))}
    list = list.select{ |country| (max[1]..(max[1] + dgs - 1)).cover?(Integer(country.cap_coord_ew + 180))}
    #find out all countries that are in the dgs*dgs block we just found
    return [list, convert_coord(max[0], "latitude"), convert_coord(max[0] + dgs, "latitude"), convert_coord(max[1], "longitude"), convert_coord(max[1] + dgs, "longitude")]
  end

  def convert_coord(num, type)
    #called only by find_most_capital_block method, converts the index to a string showing latitude
    return "" unless [Float, Fixnum].include?(num.class) and type.class == String
    if num >= 90 and type == "latitude"
      num = num - 90
      return String(Integer(num)) + " " + String(Integer(((num) % Integer(num)) * 100)) + " S"
    elsif num < 90 and type == "latitude"
      num = 90 -num
      return String(Integer(num)) + " " + String(Integer(((num) % Integer(num)) * 100)) + " N"
    elsif num >= 180 and type == "longitude"
      num = num -180
      return String(Integer(num)) + " " + String(Integer(((num) % Integer(num)) * 100)) + " E"
    elsif num < 180 and type == "longitude"
      num = 180 -num
      return String(Integer(num)) + " " + String(Integer(((num) % Integer(num)) * 100)) + " W"
    else
      return ""
    end
  end

#end of class
end