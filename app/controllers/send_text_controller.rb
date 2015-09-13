class SendTextController < ApplicationController

	def index
	end

	def process_sms
		from_number = params["From"]
		@user = User.new

		if !(User.where(phone_number: 'from_number').nil?) && !(User.where(phone_number: 'from_number').location.nil?)
			@user = User.find_by phone_number: from_number
			@latitude = @user.latitude
			@longitude = @user.longitude
			@location = @user.location
		else
			@location = params["Body"]
			@latitude = Geocoder.search(params["Body"])[0].latitude
			@longitude = Geocoder.search(params["Body"])[0].latitude
			@user = User.create(phone_number: from_number, latitude: @latitude, 
				longitude: @longitude)
		end

		
		ForecastIO.configure do |configuration| 
		  configuration.api_key = 'afe7d9eca604d31e23d47b7062511b0d'
		end

		@forecast = ForecastIO.forecast(@latitude, @longitude) # set weather forecast for the location

		client = Yelp::Client.new({
			consumer_key: 'pEUEGZHGXcTUlkpIzedWFQ',
			consumer_secret: 'MmDKe4b-eBzQ4d6Vm62NGXnzPqg',
			token: '_o_I1Le1TVVrFrrN-bj3jsAEupa6a0zy',
			token_secret: 'cZe24B1E23oniH6QGWMUlGDKZvY'
			})
		@response = client.search('Austin', {term:'food'})


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
