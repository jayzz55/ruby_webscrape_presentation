require 'capybara'
require 'capybara/poltergeist'

include Capybara::DSL

Capybara.default_driver = :poltergeist

#visit the site
visit "http://salefinder.com.au/Woolworths-catalogue"

#set the location to Melbourne, 3000
page.execute_script("$.cookie('postcodeId', 5188)")
page.execute_script("$.cookie('regionName', 'MELBOURNE, 3000')")

#re-visit the site
visit "http://salefinder.com.au/Woolworths-catalogue"

#display set location
location = page.find('span#header-region').text.strip
p location

first_page = 1
max_page = 2
page_number = 1


#loop from first_page to max_page
(page_number..max_page).each do |num|

  p page.find('a.pagenumsSelected').text
  page_number = num

  #get the price information data on each item on a page
  all('div.item-landscape').each do |item|
    p description = item.find('span.item-details h1 a').text
    p price = item.first('span.price').text if item.first('span.price')
    unit_price = item.first('span.comparative-text').text if item.first('span.comparative-text')
    price_description = item.find('div.price-options').text if item.find('div.price-options')
    price_description.slice!(price) if price
    price_description.slice!(unit_price) if unit_price
    p price_description if item.find('div.price-options')
    p unit_price if item.first('span.comparative-text')
  end

  p "-------------------- page #{num} --------------"

end
