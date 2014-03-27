module HttpHelpers
  def stub_http(from, subject, text,to)
    stub_request(:post, "https://api:key-5nf12qypu5-l7q1-lfhjazkd6xj97d75@api.mailgun.net/v2/app23401830.mailgun.org/messages").
            with(:body => {"from"=>from,
                           "subject"=>subject,
                           "text"=>text,
                           "to"=>to},
                 :headers => {'Accept'=>'*/*; q=0.5, application/xml',
                              'Accept-Encoding'=>'gzip, deflate',
                              'Content-Type'=>'application/x-www-form-urlencoded',
                              'User-Agent'=>'Ruby'}).
       to_return(:status => 200, :body => "", :headers => {})
  end
end