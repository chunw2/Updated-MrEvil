require "sinatra"
require "sinatra/reloader" if development?
require "twilio-ruby"
require "giphy"
require "rake"

require "sinatra/activerecord"



require "json"
require 'chronic'



configure :development do
  require 'dotenv'
  Dotenv.load
end

require_relative './models/user'

enable :sessions 


# -------------   Adding Giphy -----------------
def giphy_for query
  
  Giphy::Configuration.configure do |config|
    config.api_key = ENV["GIPHY_API_KEY"]
  end
  
  results = Giphy.search(query,{limit:15})
   
  unless results.empty?
    gif = results.sample.original_image.url
    return gif.to_s
     
  else
    return nil
  end

end
 

# --------------------- Conversation Details ------------------------

def determine_response body, sender
 body = body.downcase.strip 
 media = nil
 #time = params[:time]
 #month = params[:month]
 #day = params[:day]
 session[:intent] ||= nil
 message = ""
 thanks = ["No worries.", "You are welcome.", "No prob.", "My pleasure.", "Glad to help."]

 puts "Body is " + body.to_s  # more a sanity check thing

 if body == "hi" || body == "who" || body == "what" 
   message = "Hey, need my help? I am Sally, a fake calling bot who can help you get out of awkward situations. Type 'how' to learn the ways to set calls."
   media = giphy_for "hello"
 elsif body == "how"
   message = "To manage call settings,  simply type 'set call' or 'cancel call'. Or need some fake bio from me? Type 'fact'."

 elsif body == "call"

  client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]

  call = client.calls.create(
      from: ENV["TWILIO_FROM"],
      to: +13369349080,
      url: "https://drive.google.com/file/d/1k9-l9gfbnGE-MjKY6qpA7eM_xnE69zFS/view?usp=sharing"
   )
  puts call.to
 
 elsif body.include? "fact"
   message = array_of_lines = IO.readlines("facts.txt").sample
   
 elsif body.include? "thanks"
   message = thanks.sample
   media = giphy_for "no problem"
   
 elsif body == "set call" 
   message = "What time would you like to set it for? Say something like 'today at 3 pm' or 'in 10 minute'. Type 'call' for immediate calls."
   session[:intent] = "set_alarm_time"
   
 elsif session[:intent] == "set_alarm_time" 
   
   alarm_time = Chronic.parse( body )
   
   if alarm_time.nil? 
     message = "I didn't get that. Try typing your call time like 'tomorrow at 9am' or '5pm'"
   else 
     message = "I've set it for #{body}. Type 'cancel call' if you made a mistake. Don't forget to unmute your phone for the incoming call from me."
     #require_relative './models/task'
     #session[:intent] = "set_alarm_date"
  #elsif session[:intent] == "set_alarm_date" && body.to_i > 0
     # you'd actually want to set this.
     #message = "I've set it for #{body}"
     #session[:intent] = "set_alarm_date"
    
     puts "Number is #{sender}"
     user = User.where( number:sender ).first_or_create
     user.number = sender
     user.alarm = Chronic.parse( body )
     user.save!
     
     puts user.to_json
     #message = "I've set it for #{body}"
 end 
 
    
 elsif body == "cancel call"
    message = "What's the time you would like to cancel?"
    session[:intent] = "cancel_alarm_time"
 elsif session[:intent] == "cancel_alarm_time" && body.to_i > 0 
     message = "I've cancelled the one at #{body}."
     #require_relative './models/task'
     #session[:intent] = "cancel_alarm_date"
  #elsif session[:intent] == "cancel_alarm_date" 
     # you'd actually want to set this.
     #message = "I've set it for #{body}"
     #session[:intent] = "set_alarm_date"
 else
    message = "Hmmm...Not sure what you just said. Try type in something else. "
 end 
 return message, media
end


 

# -------------------------- Sign Up ------------------------------
get "/" do
  erb :signup
end

post "/signup" do

  client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
  
  # "welcoming" message send to users
  message = "Hi " + params[:first_name] + ", I am Sally, a fake calling bot who can help you get out of awkward situations."
  
  client.api.account.messages.create(
    from: ENV["TWILIO_FROM"],
    to: params[:number],
    body: message
  )
  # message show on the signup webpage
	"Successfully signed up! You'll receive a text message in a few minutes from Mr.Evil. "
end


# ---------------------- Interactive SMS ----------------------------
get "/incoming/sms" do
    body = params[:Body] || ""
    sender = params[:From] || ""
    media = nil

    message, media = determine_response body, sender
    #media = nil
    
    # Build a twilio response object 
    twiml = Twilio::TwiML::MessagingResponse.new do |r|
      r.message do |m|

        # add the text of the response
        m.body( message )
			
        #add media if it is defined
        unless media.nil?
          m.media( media )
        end
      end
    end
	
    # send a response to twilio 
    content_type "text/xml"
    twiml.to_s
  
end


get "/users" do
  User.all.to_json
end
