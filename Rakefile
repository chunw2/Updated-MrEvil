require "sinatra"
require "sinatra/activerecord/rake"
require "rake"
require 'twilio-ruby'
require 'giphy'

require "./appevil"

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
  
  # body = params[:Body] || ""
#   sender = params[:From] || ""
#   media = nil
#
#   message, media = determine_response body, sender
#
#   def determine_response body, sender
#   body = body.downcase.strip
  
  User.all.each do |user|
  
    #loop over all users
    #...
    
    puts "Found User:"
  
    puts " User alarm is #{user.alarm} "
    puts " User alarm is #{user.number} "
  
    if (not user.alarm.nil?) and Time.now > user.alarm 
      
      if not user.number.empty? 

        client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]

        call = client.calls.create(
            from: ENV["TWILIO_FROM"],
            to: user.number,
            url: "https://drive.google.com/file/d/1k9-l9gfbnGE-MjKY6qpA7eM_xnE69zFS/view?usp=sharing"
            )
        puts call.to

      end 
      
      #user.alarm = user.alarm + 10.minutes
      user.alarm = nil
      user.save!

    else
      # handle error case
    end
    
  end
  
  
  #user = User.where( id: 4 ).first
  

  
  #user.alarm = nil
  #user.save
  
end