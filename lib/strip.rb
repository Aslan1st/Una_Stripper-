require 'nokogiri'
require 'open-uri'
require 'nokogiri-pretty'

WIN_COMBINATIONS = [
    "1:00 PM - 3:00 PM",
    "4:30 PM - 7:00 PM",
    "7:30 PM - 10:00 PM",
    "10:30 PM - 1:00 AM",
    "1:00 AM - 4:00 AM",
  ]

def loop_webpages(x)
  base_page = "https://www.smallslive.com/events/calendar/?week="
  i=0
  x.times do
    File.open("./temp_#{i}.xml","w") do |f|
      doc = base_page + i.to_s
      html = Nokogiri::HTML(open(doc))
      pretty_doc = html.human
      f.write(pretty_doc)
      puts doc
      parse_data(f)
    end
    i += 1
  end
end

def parse_data(file_name)
  i = 2
  doc = Nokogiri::XML(File.open(file_name))
  event = doc.at('section[class="schedule flex container"]')
  # need to build out a loop event_node function... event_node already works on event FYI
  # I need to build it so I can print out inportant info about that particular show
  # .xpath(dd) gives me all the artists and IDs
  #.children.children.text & .attribute('data-event-id').value
  #data_position = 'div[data-position=' + '"' + "#{i}" + '"]'
  #event_data = event.at("#{data_position}")
  event_node = event.xpath('//dt')
  #index of each event to coorelate with .xpath('//dd')
  index = 0
  event_node.each do |f|
    event_time = f.children.text
    output = won?(event_time)
    if output!=true
      puts "#{event_time} <== YOU'RE A FAILURE BUT DON'T YOU DARE CRY"
      handle_bad_event(event, index)
    end
    index += 1
  end
  event_number = event_node.length
  puts "#{event_number} events checked for errors"
  #File.open("temp_-1.xml", 'w') {|f| f.puts pretty.to_xml}
end

def won?(event_time)
  if (WIN_COMBINATIONS.any?{|combo| combo == event_time})
    #puts "YOU WIN!!!"
    #return "#{event_time} is a good time range"
    true
  else
    false
  end
end

#.children.children.text & .attribute('data-event-id').value
def handle_bad_event(event, index)
  event_node = event.xpath('//dd')
  this_event = event_node[index]
  artist = this_event.children.children.text
  id = this_event.attribute('data-event-id').value
  puts "The event is called #{artist} and the id is #{id}"
end


#def each_webpage(doc)
#  yield
#      doc = Nokogiri::HTML(open(doc))
#      pretty_doc = doc.human
#      f.write(pretty_doc)
#    end
#end
