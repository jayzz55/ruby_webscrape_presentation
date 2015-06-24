require 'open-uri'
require 'mechanize'
 
url = "http://salefinder.com.au/Woolworths-catalogue"
agent = Mechanize.new
page = agent.get(url)

agent.page.forms[1]["locationSearch"] = "Melbourne, 3000"
agent.page.forms[1].submit
p agent.page.forms[1].fields

parsed_page = page.parser
location = []
item_name = []

parsed_page.css("#header-region").each do |line|
 location << line.text.strip
end

parsed_page.css("span.item-details h1 a").each do |line|
 item_name << line.text.strip
end

p "*** LOCATION ***"
p location[0]

p "*** ITEM ***"
p item_name
