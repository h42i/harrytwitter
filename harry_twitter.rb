require 'json'
require 'cinch'
require 'serialport'
require 'tweetstream'

sp = SerialPort.new "/dev/ttyUSB0", 19200

file = File.read('.././twitter.json')
json = JSON.parse(file)

y = 0

@a = 0
@b = 23
@parts = Array.new
@parts_sorted = Array.new

TweetStream.configure do |config|
  config.consumer_key       = json["consumer_key"]
  config.consumer_secret    = json["consumer_secret"]
  config.oauth_token        = json["oauth_token"]
  config.oauth_token_secret = json["oauth_token_secret"]
  config.auth_method        = :oauth
end

TweetStream::Client.new.track('#harryplotter', '#harryplottr') do |status|
  y += 200
  @tweet = "[#{status.user.screen_name}] #{status.text}"
  @numparts = (161 / 23).to_i
  (@numparts + 1).times do |n|
    puts n
    @parts << ([@tweet[@a..@b]])
    @a = @b
    @b = @a + 23
  end
  
  @parts.reverse_each do |x|
    if(!(x == [nil]))
      @parts_sorted << x
    end
  end
 
  sp.write("IN;DT*,1;PU0,#{y};SI0.5,0.5;LB#{'-'*20}*;")
  @parts_sorted.each do |x|
    sp.write("IN;DT*,1;PU0,#{y+200};SI0.5,0.5;LB#{@x}*;")
  end	 
  sp.write("IN;DT*,1;PU0,#{y+400};SI0.5,0.5;LB#{'-'*20}*;")
end



