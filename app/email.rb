class Email

  def initialize(from, to, subject, text)
    send_message(from, to, subject, text)
  end

  def send_password_token(from, to, subject, text)
    RestClient.post API_URL+"/messages",
      :from => from,
      :to => to,
      :subject => subject,
      :text => text
  end

end