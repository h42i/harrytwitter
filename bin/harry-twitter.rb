#!/usr/bin/ruby

require 'json'
require 'cinch'
require 'serialport'
require 'tweetstream'

# Initializing the serial port
sp = SerialPort.new "/dev/ttyS0", 19200

# Reading and parsing the JSON file with Twitter credentials
file = File.read('.././twitter.json')
json = JSON.parse(file)

# This is the holy variable for the y-axis on the plotter
y = 0

# Things for breaking down the tweets to a "plottable" length
#@a = 0
#@b = 23
#@parts = Array.new

# Some Twitter magic
TweetStream.configure do |config|
  config.consumer_key       = json["consumer_key"]
  config.consumer_secret    = json["consumer_secret"]
  config.oauth_token        = json["oauth_token"]
  config.oauth_token_secret = json["oauth_token_secret"]
  config.auth_method        = :oauth
end

# Here we check if the tweet contains our hashtag, #harryplotter or #harryplottr
TweetStream::Client.new.track('#harryplotter', '#harryplottr') do |status|
  @a = 0; @b = 23; @parts = Array.new 
  y += 200
  @tweet = "[@#{status.user.screen_name}] #{status.text}"
  puts "TWEET: #{@tweet}"
  ((@tweet.length / 23) + 1).times do
    @apart = @tweet[@a..@b]
    @parts << @apart unless @apart.empty?
    @a = @b
    @b = @a + 23
  end
  
  # This is important. Very important.
  @parts.reverse!
  
  # Plotting the tweet
  sp.write("IN;DT*,1;PU0,#{y};SI0.5,0.5;LB#{'-'*20}*;")
  @parts.each do |x|
    y += 300
    sp.write("IN;DT*,1;PU0,#{y};SI0.5,0.5;LB#{x}*;")
  end	
  y += 400
  sp.write("IN;DT*,1;PU0,#{y};SI0.5,0.5;LB#{'-'*20}*;")
end
