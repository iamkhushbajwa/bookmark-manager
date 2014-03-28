require './app/server'

configure :production do
  set :db_name, 'ddn1h1f6fhbue0'
  set :db_user, 'ptlkvhbohxzoig'
  set :db_password, 'Xvh-0E-O1ynUX4D6_OLUhdXCfp'
  set :db_server, 'ec2-54-217-208-135.eu-west-1.compute.amazonaws.com'
end

run Sinatra::Application
