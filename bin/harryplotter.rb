#!/usr/bin/ruby

require 'json'
require 'serialport'
require 'tweetstream'

# Read config
# Nope.

# Initializing the serial port
sp = SerialPort.new "/dev/ttyS0", 19200

# Reading and parsing the JSON file with the Twitter credentials
creds = JSON.parse(".././twitter.json")

# This is the holy variable for the y-axis on the plotter
y = 0

# Some Twitter magic
TweetStream.configure do |config|
  config.consumer_key       = creds["consumer_key"]
  config.consumer_secret    = creds["consumer_secret"]
  config.oauth_token        = creds["oauth_token"]
  config.oauth_token_secret = creds["oauth_token_secret"]
  config.auth_method        = :oauth
end

# Here we check if the tweet contains our hashtag, #harryplotter or #harryplottr
TweetStream::Client.new.track(['#harryplotter', '#harryplottr', '@harryplottr', '@h42i', 
                              '#hasileaks', '@hasileaks']) do |status|
  
  @parts = Array.new 
  
  y += 200
  @tweet = "[@#{status.user.screen_name}] #{status.text}".split
  @string = ""
  @tweet.each do |n|
    if @string.length < 43
      @string = @string + n + " "
    else
      @parts << @string
      string = ""
    end
  end
      
  # This is important. Very important.
  @parts.reverse!

  # Plotting the tweet
  sp.write("IN;DT*,1;RO90;PU0,#{y};SI0.3,0.3;LB#{'-'*43}*;")
  @parts.each do |x|
    y += 300
    sp.write("IN;DT*,1;RO90;PU0,#{y};SI0.3,0.3;LB#{x}*;")
  end	
  y += 400
  sp.write("IN;DT*,1;RO90;PU0,#{y};SI0.3,0.3;LB#{'-'*43}*;")
end
