require 'rest-client'

API_KEY = ENV["MAILGUN_API_KEY"]
API_URL = "https://api:#{API_KEY}@api.mailgun.net/v2/app23401830.mailgun.org"

class Email

  def initialize(from, to, subject, text)
    send_message(from, to, subject, text)
  end

  def send_message(from, to, subject, text)
    RestClient.post API_URL+"/messages",
      :from => from,
      :to => to,
      :subject => subject,
      :text => text
  end

end