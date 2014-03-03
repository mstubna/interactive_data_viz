require_relative 'data/life_expectancy_fertility_rate/parser'
require_relative 'data/american_time_use_survey/parser'

def write_data_to_json(data, file_name)
  require 'json'  
  File.open(file_name, "wt") do |file|  
    file.write 'data = ' + data.to_json
  end
end

task :preview do
  system "middleman --port=4569"
end

task :build do
  system "middleman build --clean"
end

task :sync do
  system "middleman sync"
end