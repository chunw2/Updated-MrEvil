require "sinatra"
require 'twilio-ruby'
require 'giphy'

require "./appevil"
require "rake"
require "sinatra/activerecord/rake"

# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)
configure :development do
  require 'dotenv'
  Dotenv.load
end


# def determine_response alarm
#   alarm = params[:time]

def determine_response body
 body = body.downcase.strip 
 media = nil
 session[:intent] ||= nil
 message = ""
end

alarm_time = Chronic.parse( "body" )

desc 'outputs hello world to the terminal'
task :hello_world do 
  puts "Hello World from Rake!"
end



desc 'sends a test twilio SMS to your number'
task :send_sms do 
  
  #if session[:intent] == "set_alarm_time" && body.to_i > 0 
  
  client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]

  # confirmation if statement for my EvilBot on the night before the alarm
  message = "It seems like you have an alarm set at #{body} tomorrow. Please unmute your phone before you go to bed."
  
  client.api.account.messages.create(
    from: ENV["TWILIO_FROM"],
    to: ENV["MY_NUMBER"],
    body: message
  )
	
  puts "Send an SMS"  
  
  #else
  #end
  
end



desc 'make an alarm call to your number'
task :make_alarmcall do 
  
  if Time.now = alarm_time
  
  client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
  
  call = client.calls.create(
      from: ENV["TWILIO_FROM"],
      to: ENV["MY_NUMBER"],
      url: "https://drive.google.com/file/d/1k9-l9gfbnGE-MjKY6qpA7eM_xnE69zFS/view?usp=sharing"
   )
  puts call.to
  
  else
  end
  
end
  
 