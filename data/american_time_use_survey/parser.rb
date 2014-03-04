module AmericanTimeUseSurvey
  
  class Parser
    
    # read the data in all the files
    def read_raw_data
      data = []
      ['03_07', '07_11'].each do |id|
        data << read_raw_data_file("data/american_time_use_survey/data_#{id}.txt")
      end
      return data
    end
    
    # read the data in a single file
    def read_raw_data_file(fn)      
      # alternating rows of data contain a) activity name, and b) activity % by hour [0-23]
      activity_name = nil
      activities = []
      File.open(fn, 'r') do |f|
        f.each_line.with_index do |line, i|
          line = line.gsub("\n",'')
          if i % 2 == 0
            activity_name = line
          else
            activities << {name: activity_name, values: line.split(' ').map {|x| x.to_f} }
          end
        end
      end

      return activities
    end        

  end
end

task :create_american_time_use_survey_json do  
  data = (AmericanTimeUseSurvey::Parser.new).read_raw_data
  write_data_to_json data, 'source/american_time_use_survey_data.js'
end
