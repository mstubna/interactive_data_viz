module LifeExpectancy
  
  class Parser
    require 'csv'
    
    def read_raw_data
      countries = []
      years = []
      country = nil

      CSV.read("data/life_expectancy_fertility_rate/data.csv").each_with_index do |row,i|

        # first row contains years
        if i == 0
          years = map_row_to_numbers(row, 'i')
          next
        end        
        
        # sequential rows contain: 1) life expectancy, 2) fertility rate, and 3) population
        country_code = row[1]
        if i % 3 == 1
          country = { country_name: row[0], country_code: country_code }
          country[:life_expectancy] = map_row_to_numbers(row, 'f')
        elsif i % 3 == 2
          country[:fertility_rate] = map_row_to_numbers(row, 'f')
        else
          country[:population] = map_row_to_numbers(row, 'i')
          countries << country
        end
      end
      
      return {years: years, countries: countries}
    end
    
    # should improve this to just interpolate missing data, not reject country entirely . . . 
    def remove_countries_with_missing_data(data)
      filtered_countries = []
      data[:countries].each do |country|
        if country[:fertility_rate].count(0) == 0 and country[:life_expectancy].count(0) == 0 and country[:population].count(0) == 0
          filtered_countries << country
        end
      end

      p "original num countries: #{data[:countries].length}"
      p "filtered num countries: #{filtered_countries.length}"

      data[:countries] = filtered_countries
      return data
    end
    
    # ignore the last two row entries (2012, 2013) because they are usually blank
    def map_row_to_numbers(row, type)
      row[4...row.length-2].map {|x| if type == 'f' then x.to_f else x.to_i end}
    end
    
  end
end

task :create_life_expectancy_json do  
  parser = LifeExpectancy::Parser.new
  data = parser.read_raw_data
  data = parser.remove_countries_with_missing_data(data)
  write_data_to_json data, 'source/life_expectancy_fertility_rate_data.js'
end
