class SendTextController < ApplicationController
	def index
	end

	def process_sms

		ForecastIO.api_key = 'afe7d9eca604d31e23d47b7062511b0d'
		@locations = Location.near(params["Body"], 50, :order => :distance)

		render 'process_sms.xml.erb', :content_type => 'text/xml'
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
