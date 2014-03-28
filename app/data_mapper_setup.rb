env = ENV["RACK_ENV"] || "development"

if env == "production"
  DataMapper.setup(:default, "postgres://ptlkvhbohxzoig:Xvh-0E-O1ynUX4D6_OLUhdXCfp@ec2-54-217-208-135.eu-west-1.compute.amazonaws.com:5432/ddn1h1f6fhbue0")
  DataMapper.finalize
  DataMapper.auto_upgrade!
else
  DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")
  DataMapper.finalize
  DataMapper.auto_upgrade!
end