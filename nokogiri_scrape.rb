require 'nokogiri'
require 'open-uri'

url = "http://salefinder.com.au/Woolworths-catalogue"
page = Nokogiri::HTML(open(url)) 
p item = page.css("span.item-details h1 a").text