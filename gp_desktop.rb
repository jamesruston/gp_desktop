#!/usr/bin/env ruby

require 'excon'
require 'json'
require 'date'

def file_path_for_race(race)
  race_name = race[:raceName].downcase.tr(' ', '_')
  "Users:james:Pictures:f1:#{race_name}.jpg"
end

response = Excon.get('http://ergast.com/api/f1/2017.json')
json = JSON.parse(response.body, symbolize_names: true)

races = json.dig(:MRData, :RaceTable, :Races)

races.each do |race|
  standard_file_path = "/" + file_path_for_race(race).tr(':', '/')
  if ! File.exists? standard_file_path
    puts "Warning: Image not found at #{standard_file_path}"
  end
end

next_race = races&.detect { |race| Date.today < Date.parse(race[:date]) }

race_date = Date.parse(next_race[:date])

days_until = (race_date - Date.today).to_i

puts next_race[:Circuit][:Location][:country] + " :car: " + days_until.to_s + " days"

%x( osascript -e 'tell Application "Finder"' -e 'set the desktop picture to {"#{file_path_for_race(next_race)}"} as alias' -e 'end tell' )