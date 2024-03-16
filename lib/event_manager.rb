require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'time'
require 'date'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end
=begin
def clean_homephone(homephone)
  pattern = /[()-]/
  homephone = homephone.gsub(pattern,"")
  if homephone.length === 10
    homephone
  elsif homephone.length < 10
    homephone = "0000000000"
  elsif homephone.length === 11 && homephone.to_s[0].to_i === 1
      homephone = homephone[1..10]
  elsif homephone.length === 11 && homephone.to_s[0].to_i != 1
        homephone = "0000000000"
  else
    #puts "else branch"
    homephone = "0000000000"
  end
  homephone
end
=end
#=begin
def clean_homephone(homephone)
  digits_only = homephone.gsub(/[^0-9]/,"")
  if digits_only.start_with?('1') && homephone.length === 11
    homephone = digits_only[-10..-1]
  else
    homephone = digits_only
  end
  homephone.rjust(10,'0')
end
#=end

def legislator_by_zipcode(_zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  begin
    legislators = civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: %w[legislatorUpperBody legislatorLowerBody]
    ).officials
  rescue
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id,form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts form_letter
 end
end


puts 'EventManager initialized.'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter

def cleanTime(time)
  time = time.split(" ").slice(1)
end

def getHour(time)
  hour = time.split(":").slice(0).to_i
  #hour.group_by{|i| i}.max_by {|_,v|v.length}.first
end

def mode(arr)
  arr.group_by{|i| i}.max_by {|_,v|v.length}.first
end

def cleanDate(date)
  date = date.split(" ").slice(0)
  date = Date.strptime(date, "%m/%d/%y").wday
end

hourArr = []
dateArr = []
contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  time = cleanTime(row[:regdate])
  hour = getHour(time)
  date = cleanDate(row[:regdate])
  homephone = clean_homephone(row[:homephone])
  legislators = legislator_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  save_thank_you_letter(id,form_letter)
  hourArr << hour
  dateArr << date
  p "#{homephone}"
end

popularHour = mode(hourArr)
popularDate = Date::DAYNAMES[mode(dateArr)]
p popularHour
p popularDate



#get date string
#convert dates to day of week
#pop dates into array
#find mode

=begin
//when are peak reg hours
time = ?
turn into array and split 1,11/12/08 10:47
time.parse
=end
