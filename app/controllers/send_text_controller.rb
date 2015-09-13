class SendTextController < ApplicationController
	@@input_count = 0
	@@location = Geocoder.search("Austin, TX")
	@@plain_location = ''

	def index
	end

	def process_sms
		if @@input_count == 0
			@@location = Geocoder.search(params["Body"])
			@@plain_location = params["Body"]
		end
		@body = params["Body"] #  set the command to equal the plain text message

		@@input_count = 1
		
		ForecastIO.configure do |configuration| 
		  configuration.api_key = 'afe7d9eca604d31e23d47b7062511b0d'
		end

		@forecast = ForecastIO.forecast(@@location[0].latitude, @@location[0].longitude) # set weather forecast for the location

		client = Yelp::Client.new({
			consumer_key: 'pEUEGZHGXcTUlkpIzedWFQ',
			consumer_secret: 'MmDKe4b-eBzQ4d6Vm62NGXnzPqg',
			token: '_o_I1Le1TVVrFrrN-bj3jsAEupa6a0zy',
			token_secret: 'cZe24B1E23oniH6QGWMUlGDKZvY'
			})
		@response = client.search(@@plain_location)

		if @body.downcase == 'weather'
			render 'weather.xml.erb', :content_type => 'text/xml' # send text message to user
		elsif @body.downcase == 'restaurants' || @body.downcase == 'food'
			render 'restaurants.xml.erb', :content_type => 'text/xml'
		elsif @body.downcase == 'done'
			render 'stop.xml.erb', :content_type => 'text/xml'
			@@input_count = 0
		elsif @body.downcase != 'stop' && @body.downcase != 'start'
			render 'other.xml.erb', :content_type => 'text/xml'
		end

	end

	def send_text_message
    number_to_send_to = params[:number_to_send_to]
    message = params[:message]

    twilio_sid = "AC0efcecadadf271dda76f44c41111e345"
    twilio_token = "234321480deab317429df46b3c073a4b"
    twilio_phone_number = "8327421996"

    @twilio_client = Twilio::REST::Client.new twilio_sid, twilio_token

    @twilio_client.account.sms.messages.create(
      :from => "+1#{twilio_phone_number}",
      :to => number_to_send_to,
      :body => "#{message}"
    )

    render 'index'
  end
end
