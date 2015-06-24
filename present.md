title: Webscraping with Ruby
theme: sudodoki/reveal-cleaver-theme
author:
  name: Jaya Wijono
  twitter: jayzz55
  url: https://github.com/Jayzz55
output: present_ruby.html
controls: true

--

# Webscraping with Ruby

--

### What is WebScraping?

![WebScraping](http://ruby.bastardsbook.com/assets/images/lede/web-scraping.jpg)

--

### What is WebScraping?

Grabbing the data you want from the internet

--

### WHY do I care?

![meme](http://cdn.meme.am/instances/500x/62425258.jpg)

--

# The Journey

![image](https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcT3ul-0w8HRF03PdKF1t5Bd6Pt0bAG_EnEahYV6sY5YCNjzuwJi2A)

--

### Prologue to the journey

![meme](http://rs1img.memecdn.com/after-wedding_o_1018854.jpg)

--

## Problems

Finding grocery specials information **that matters!**

--

## Solution

There is **http://salefinder.com.au/**

But this is not good enough!

--

# Attempt #1

### Using Nokogiri

--

### Attempt #1 - Using Nokogiri

```ruby
require 'nokogiri'
require 'open-uri'
```

--

### Attempt #1 - Using Nokogiri

```ruby
url = "http://salefinder.com.au/Woolworths-catalogue"
page = Nokogiri::HTML(open(url)) 
p item = page.css("span.item-details h1 a").text
```

--

### Attempt #1 - Using Nokogiri

**SEE THIS IN ACTION**

--

### Attempt #1 - Using Nokogiri

![image](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR00mcGw-FFwwXkEuxrYum9WnJqunZmjKGAEz5FWtTl27nhZVeQ)

--

### Attempt #1 - Using Nokogiri

**BUT** data scrapped is not from Melbourne :(

--

# Attempt #2

### Using Mechanize

--

### Attempt #2 - Using Mechanize

```ruby
require 'mechanize'
```

--

### Attempt #2 - Using Mechanize

```ruby
url = "http://salefinder.com.au/Woolworths-catalogue"
agent = Mechanize.new
page = agent.get(url)
```

--

### Attempt #2 - Using Mechanize

To find the first form of the retrieved page
(Mechanize::Page instance's parser method in action)

```ruby
agent.page.parser.css('form')[1]
```

However, the Mechanize gem gives us a handy shortcut:

```ruby
agent.page.forms[1]
```

--

### Attempt #2 - Using Mechanize

To set the field using Mechanize agent instance

```ruby
agent.page.forms[1]["locationSearch"] = "Melbourne, 3000"
```

To submit the form

```ruby
agent.page.forms[1].submit
```

--

### Attempt #2 - Using Mechanize

**SEE THIS IN ACTION**

--

### Attempt #2 - Using Mechanize

![image](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSeoPX4r3d8U0HjNNDoa6wB94o6wW4inEIoK-3q-GSQk86d2cNCqA)

Because of **JAVASCRIPT!!**

--

# Attempt #3

### Using Capybara

--

### Attempt #3 - Using Capybara

```ruby
require 'capybara'
require 'capybara/poltergeist'

include Capybara::DSL

Capybara.default_driver = :poltergeist
```

--

### Attempt #3 - Using Capybara

Visiting the url

```ruby
visit "http://salefinder.com.au/Woolworths-catalogue"
```

Setting location through Capybara::Session#execute_script

```ruby
page.execute_script("$.cookie('postcodeId', 5188)")
page.execute_script("$.cookie('regionName', 'MELBOURNE, 3000')")
```

--

### Attempt #3 - Using Capybara

To parse the page:
```ruby
description = item.find('span#header-region').text
```

--

### Attempt #3 - Using Capybara

**SEE THIS IN ACTION**

--

### Attempt #3 - Using Capybara

![image](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSocmRumlxxKy2pN-ADX6DTyHN3aGRNKj04VenHxUX5b3WGDAI6oQ)

--

# Rails Application & Testing

### http://savvy-mom.herokuapp.com/

--

### Rails Application & Testing

Create delayed jobs to do scraping work (in app/jobs)

```ruby
class CheckCataloguesJob < ActiveJob::Base
end
```

Calling the jobs

```ruby
CheckCataloguesJob.perform_later
```

--

### Rails Application & Testing

Create task to schedule and manage jobs in Heroku / using Whenever Gem (in lib/tasks)

```ruby
namespace :scraper do
  desc "test running jobs"
  task check_catalogues: :environment do
    require './app/jobs/check_catalogues_job.rb'
    CheckCataloguesJob.perform_later
  end
end
```

--

### Rails Application & Testing

Testing:

Use Rspec to test the job's algorithm to return expected value

**BUT** How do you test the web scraper is going out and scrape the data as expected?

--

### Rails Application & Testing

**Puffing Billy** to the rescue!

A rewriting web proxy for testing interactions between your browser and
external sites. Works with ruby + rspec.

Puffing Billy is like [webmock](https://github.com/bblimke/webmock) or
[VCR](https://github.com/vcr/vcr), but for your browser.

![image](http://upload.wikimedia.org/wikipedia/commons/0/01/Puffing_Billy_1862.jpg)

--

### Rails Application & Testing

**WAIT A MINUTE!** The scraping job is running on Poltegeist, and the spec to test this job is also running on Poltergeist.

So running a Poltergeist on top of another Poltergeist???

--

### Rails Application & Testing

**Selenium** rescue the day for testing!

```ruby
require 'rails_helper'
require 'spec_helper'
require 'billy/rspec'
require './app/jobs/check_catalogues_job.rb'

feature CheckCataloguesJob do

  before do
    @original_driver = Capybara.default_driver
    Capybara.default_driver = :selenium_chrome_billy
  end

  after do
    Capybara.default_driver = @original_driver
  end
  
end
```

--

### Rails Application & Testing

Testing the web scraping jobs is behaving as expected:

```ruby
scenario 'CheckCataloguesJob scrape expected data' do
  expect(CheckCataloguesJob.new.scrape_published_catalogue_nums).to eq(["8390", "8451", "8368", "8437", "8356"])
end
```

--

### Rails Application & Testing

Testing the web scraping jobs is behaving as expected:

**SEE THIS IN ACTION**

--

### Rails Application & Testing

Check it out:

http://savvy-mom.herokuapp.com/

https://github.com/Jayzz55/savvy_mom

--

# Conclusion

![image](https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcSyucxgJBIS8iakDv6D7Z-WmQlcVIaaPNd9t8LHCC_0wQb5hXaD)

--

# Thank You!

Contact: 

Jayzzwijono@yahoo.com


