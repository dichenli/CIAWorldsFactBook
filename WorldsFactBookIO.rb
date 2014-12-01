require_relative 'HW2_part2'


class WorldsFactBookIO

  def initialize
    puts "Initializing, please wait. This may take a few minutes..."
    @wfb = WorldsFactBook.new
    puts "Initialization done!"
    input_output
  end

  def input_output # This masters the sequence of questions showing up.
    puts "\n"
    io_geohazard_countries
    puts "\n"
    io_lowest_point_country
    puts "\n"
    io_country_in_hemisphere
    puts "\n"
    io_continent_parties_num
    puts "\n"
    io_elec_consume_rank
    puts "\n"
    io_religion_percent
    puts "\n"
    io_religion_percent
    puts "\n"
    io_land_lock_one_neighbor
    puts "\n"
    io_coastline_rank
    puts "\n"
    io_maximize_capital
    puts "\n"
    io_resource
  end

  #all the io_ methods represents the methods for user to enter values and printing out results
  def io_geohazard_countries
    puts "Now we will list countries in a continent that is prone to one type of natural hazard."
    conti = input_continent #input_continent is a method to make sure the input is one continent
    haz = input_hazards #make sure the input is one type of hazard
    list = @wfb.list_geohazard_countries(conti, haz)
    puts "Below is a list of countries in #{conti} that has #{haz}"
    return nil if abnormal?(list) #If there is no bug, this will never happen. So it's just for a sign of bug
    list.each{|country_name| puts country_name}
  end

  def io_lowest_point_country #please refer to the descriptions in "puts" lines for explanation of method
    puts "Now we will list the country that has the lowest point of altitude in a continent."
    conti = input_continent
    country_name = @wfb.lowest_point_country(conti)
    return nil if abnormal?(country_name)
    puts "#{country_name} has the lowest altitude point in #{conti}."
  end

  def io_country_in_hemisphere#please refer to the descriptions in "puts" lines for explanation of method
    puts "Now we will list all countries in one hemisphere of earth."
    hem = input_hemisphere
    list = @wfb.countries_hemisphere(hem)
    return nil if abnormal?(list)
    puts "Below is a list of countries in #{hem} hemisphere"
    list.each{|country| puts country.name}
  end

  def io_continent_parties_num#please refer to the descriptions in "puts" lines for explanation of method
    puts "Now we will list countries in a continent that has more than certain number of political parties."
    conti = input_continent
    num = input_integer
    list = @wfb.continent_parties_num(conti, num)
    return nil if abnormal?(list)
    puts "Below are the countries with more than #{num} parties in #{conti}"
    list.each{|country| puts country.name}
  end

  def io_elec_consume_rank#please refer to the descriptions in "puts" lines for explanation of method
    puts "Now we will list the first # of countries in the world with the highest electricity consumption per capita:"
    num = input_integer
    list = @wfb.elec_consume_rank(num)
    return nil if abnormal?(list)
    puts "Below are the top #{num} countries in the world with the highest electricity consumption per capita:"
    list.each{|country| puts country.name + "\t" +"%.0f" %country.elec_consume_per_capita + " kWh/capita"}
  end

  def io_religion_percent#please refer to the descriptions in "puts" lines for explanation of method
    puts "Now we will list the countries in the world in where the dominate religion takes more than (or less than) certain percent of population"
    puts "Please enter a '>' or '<' sign followed by a percent. For example: > 80%"
    sign = {">" => 1, "<" => -1}
    while true #The input must match >80%, < 50%, etc. A > or < sign and % is needed. number can be float
      percent = gets.chomp
      matched = percent.match(/([><]) *(\d+\.*\d*) *%/)
      #match[1] is > or < sign, match[2] is a percent number
      break if matched != nil and sign[matched[1]] != nil
      puts "Wrong input! please enter again: (such as <50%)"
    end
    list = @wfb.religion_percent(percent)
    return nil if abnormal?(list)
    puts "Below is the list for matched countries for religions"
    list.each{|country| print country.name, "\t", country.dominate_religion, "\t", country.domi_relig_percent, "%\n"}
  end

  def io_land_lock_one_neighbor#please refer to the descriptions in "puts" lines for explanation of method
    list = @wfb.landlocked_single_neighbor
    #select countries landlocked and has only one boundary country
    puts "Below are countries that are landlocked by a single country"
    list.each{|country| puts country.name}
  end

  def io_maximize_capital#please refer to the descriptions in "puts" lines for explanation of method
    puts "Extra Credit question, given a number that is the extent of lat/long in one block on earth,
    find the lat/long coordinates and the list of countries/capitals so that the number of capitals is maximized."
    num = input_integer
    result = @wfb.find_most_capital_block(num)
    puts "The region has been found:"
    puts "Latitude: From " + result[1] + " to " + result[2]
    puts "Longitude: From " + result[3] + " to " + result[4]
    puts "Below is the list for all the countries and their capitals inside that area:"
    result[0].each{|country| puts country.name + "\t" + country.capital + "\t" + @wfb.convert_coord(country.cap_coord_sn + 90, "latitude") + "\t" + @wfb.convert_coord(country.cap_coord_ew + 180, "longitude")}
  end

  def io_coastline_rank#please refer to the descriptions in "puts" lines for explanation of method
    puts "Wild card question 1: \n Please put in a country name, this method tells the rank of its coastline length among countries"
    while true
      country = gets.chomp
      rank = @wfb.coastline_rank(country)
      break if rank != nil
      puts "Invalid name! Is the spelling of your country name wrong?"
    end
    puts "The rank of its coastline length among countries is: #{rank}"
  end

  def io_resource#please refer to the descriptions in "puts" lines for explanation of method
    puts "Extra credit, Wild card question 2: \n Please put in the name of a natural resource, this method tells which countries have such resource"
    while true
      resource = gets.chomp
      list = @wfb.country_resource(resource)
      break if list != nil
      puts "Sorry, we can't identify the name of this natural resource. Try again:"
    end
    puts "The countries with #{resource} are:"
    list.each{|country| puts country.name}
  end

  def abnormal?(arg) #return true with
    if arg == nil
      puts "No result found!"
      return true
    end
    return false
  end

  def input_hemisphere
    hemispheres = ["southeastern", "northeastern", "southwestern", "northwestern"]
    puts "Please enter one of southeastern, northeastern, southwestern, northwestern:"
    while true
      hem = gets.chomp.to_s.strip.downcase
      break if hemispheres.include?(hem)
      puts "Wrong input! please put in one of [southeastern, northeastern, southwestern, northwestern]!"
    end
    return hem
  end

  def input_integer
    puts "Please enter a number:"
    while true
      num = gets.chomp
      break if num.to_i.to_s == num#check if input is an integer
      puts "Wrong input, please enter a number:"
    end
    return num.to_i
  end

  def input_continent
    puts "What continent? Options: Asia, Africa, Europe, North America, South America, Oceania"
    continents = ["asia", "africa", "europe", "north america", "south america", "oceania"]
    while true
      conti = gets.chomp.to_s.strip.downcase
      break if continents.include?(conti)
      puts "Your input is not one of the continents, please enter again: "
    end
    return conti
  end

  def input_hazards
    print "what natural hazard? "
    hazards = ["earthquake", "flood", "drought", "tsunami", "mudslide", "typhoon", "avalanche", "storm",
               "hurricane", "windstorm", "cyclone", "forest fire", "maritime hazard", "harmattan",
               "monsoonal rain", "monsoon rain", "volcano"]
    hazards[0...-1].each{|elem| print elem + "; "}
    puts hazards[-1]
    while true
      haz = gets.chomp.to_s.strip.downcase
      break if hazards.include?(haz)
      puts "Your input is not one of the natural hazards, please enter again: "
    end
    return haz
  end

end


WorldsFactBookIO.new
