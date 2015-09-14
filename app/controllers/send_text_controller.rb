class SendTextController < ApplicationController

	def index
	end

	def process_sms
		from_number = params["From"]
		@location = ''
		@latitude = 0
		@longitude = 0

		if (User.find_by phone_number: from_number)
			# If user found
			@user = User.find_by phone_number: from_number
			@latitude = @user.latitude
			@longitude = @user.longitude
			@location = @user.location
		else
			# User not found

			@location = params["Body"]
			@cords = Geocoder.search(params["Body"])[0]
			@formatted_location = @cords.data["formatted_address"]
			#binding.pry some magic stuff the twilio guy did to see how the data was
			#coming in

			@latitude = @cords.data['geometry']['location']['lat']
			@longitude = @cords.data['geometry']['location']['lng']

			puts @location
			puts @cords
			puts @latitude
			puts @longitude

			@user = User.create(phone_number: from_number, latitude: @latitude,
				longitude: @longitude, location: @location)

			render 'city_set.xml.erb', :content_type => 'text/xml' # displays after
																													# user types in a city
		end

		ForecastIO.configure do |configuration|
		  configuration.api_key = 'afe7d9eca604d31e23d47b7062511b0d'
		end

		@forecast = ForecastIO.forecast(@latitude, @longitude) # set weather forecast using coordinates

		client = Yelp::Client.new({
			consumer_key: 'pEUEGZHGXcTUlkpIzedWFQ',
			consumer_secret: 'MmDKe4b-eBzQ4d6Vm62NGXnzPqg',
			token: '_o_I1Le1TVVrFrrN-bj3jsAEupa6a0zy',
			token_secret: 'cZe24B1E23oniH6QGWMUlGDKZvY'
			})


		if params["Body"].downcase.include?('weather')
			render 'weather.xml.erb', :content_type => 'text/xml'
		elsif params["Body"].downcase.include?('search')
			@response = client.search(@location, {term:params["Body"][7..-1]})
			render 'yelp_search.xml.erb', :content_type => 'text/xml' # display if the
			# user searches for food
		elsif params["Body"].downcase == 'done'
			@user.delete # delete the user so the next time they use the app it will
			# create a new location for them
			render 'stop.xml.erb', :content_type => 'text/xml'
		elsif params["Body"] == @location
		else
			render '404.xml.erb', :content_type => 'text/xml'
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
