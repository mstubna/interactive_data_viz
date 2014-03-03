module LifeExpectancy
  
  class Parser
    
    def read_raw_data
      # do something
      
      return {data: "here be the data"}
    end

  end
end

task :create_life_expectancy_json do  
  data = (LifeExpectancy::Parser.new).read_raw_data
  write_data_to_json data, 'source/data/life_expectancy_fertility_rate_data.js'
end
