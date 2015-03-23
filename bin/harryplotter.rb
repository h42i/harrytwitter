#!/usr/bin/env ruby

require 'json'
require 'serialport'
require 'tweetstream'

CONFIG = JSON.parse(File.read("config.json"))
TWITTR = JSON.parse(File.read(CONFIG["credentials"]))

# Initializing the serial port
sp = SerialPort.new(CONFIG["serial_port"], 19200)

# The holy variable, which holds the y-axis on the plotter
y = 0

# Some Twitter magic
TweetStream.configure do |config|
  config.consumer_key       = creds["consumer_key"]
  config.consumer_secret    = creds["consumer_secret"]
  config.oauth_token        = creds["oauth_token"]
  config.oauth_token_secret = creds["oauth_token_secret"]
  config.auth_method        = :oauth
end

TweetStream::Client.new.track(CONFIG["hashtags"]) do |status|
  
  parts = [] 
  string = ""

  y += 200
  tweet = "[@#{status.user.screen_name}] #{status.text}"
  array = tweet.split
  
  # We must determine the number of parts
  # number = (tweet.length - (tweet.length % 43)) / 43
  
  # Now, we split the tweet
  array.each do |n|
    if string.length < 43 && n != array.last
      string = string + n + " "
    elsif n == array.last
      string = string + n
      parts << string
    else
      parts << string
      string = ""
    end
  end

  # Turn it upside down!
  parts.reverse!

  # Plotting the tweet
  sp.write("IN;DT*,1;PU0,#{y};SI0.3,0.3;LB#{'-'*43}*;")
  parts.each do |x|
    y += 300
    sp.write("IN;DT*,1;PU0,#{y};SI0.3,0.3;LB#{x}*;")
  end	
  y += 400
  sp.write("IN;DT*,1;PU0,#{y};SI0.3,0.3;LB#{'-'*43}*;")
end
