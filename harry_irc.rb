require 'cinch'
require 'serialport'
require 'tweetstream'

y = 0

sp = SerialPort.new "/dev/ttyUSB0", 19200

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = "HarryPlotter"
    c.server = "irc.freenode.org"
    c.channels = ["#hodor"]
  end

  on :message do |m|
    y += 200
    @message = "#{m.time.hour}:#{m.time.min} <#{m.user}> #{m.message}".to_s
    sp.write("IN;DT*,1;PU0,#{y};SI0.25,0.25;LB#{@message}*;")
  end
end

bot.start


