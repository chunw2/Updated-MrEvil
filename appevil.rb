require "sinatra"
require "sinatra/reloader" if development?
require "twilio-ruby"
require "giphy"

enable :sessions 

configure :development do
  require 'dotenv'
  Dotenv.load
end


# -------------   Adding Giphy -----------------
def giphy_for query
  
  Giphy::Configuration.configure do |config|
    config.api_key = ENV["GIPHY_API_KEY"]
  end
  
   results = Giphy.search(query,{limit:5})
   
   unless results.empty?
     gif = results.sample.original_image.url
     return gif.to_s
     
   else
     return nil
   end
   
 end
 

# -------------------------- Sign Up ------------------------------
get "/" do
  erb :signup
end

post "/signup" do

  client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
  
  # "welcoming" message send to users
  message = "Hi " + params[:first_name] + ", Ready for Mr.Evil? I can be annoying in the morning. Respond 'Facts' to know a little bit more about me."
  
  client.api.account.messages.create(
    from: ENV["TWILIO_FROM"],
    to: params[:number],
    body: message
  )
  # message show on the signup webpage
	"Successfully sign up! You'll receive a text message in a few minutes from Mr.Evil. "
end


# ---------------------- Interactive SMS ----------------------------
get "/incoming/sms" do
    body = params[:Body] || ""
    sender = params[:From] || ""
    media = nil

      message, media = determine_response body
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
	
    # send a response to twilio 
    content_type "text/xml"
    twiml.to_s
  
end


# --------------------- Conversation Details ------------------------

def determine_response body
  body = body.downcase.strip 
  media = nil
  message = ""
 
  puts "Body is " + body.to_s  # more a sanity check thing

  if body == "hi"
    message == "what's up my friend"
    media = giphy_for "hello"
  elsif body == "who" || body == "what" 
    message == "I am Mr. Evil, an alarm you will love (and hate), lol."
  elsif body == "help" || body == "how"
    message = "Simply type 'set alarm' or 'cancel alarm' to manage alarm settings." 
  elsif body == "fact"
    message = array_of_lines = IO.readlines("facts.txt").sample
  elsif body == "call"
    call = @client.calls.create(
        from: ENV["TWILIO_FROM"],
        to: ENV["MY_NUMBER"],
        url: "https://drive.google.com/file/d/1k9-l9gfbnGE-MjKY6qpA7eM_xnE69zFS/view?usp=sharing")
    puts call.to
  else
     message == "Hmmm...Not sure what you just said. Try type in something else. "
   end 
   
   return message, media
 end
end
