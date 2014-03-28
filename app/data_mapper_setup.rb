env = ENV["RACK_ENV"] || "development"

if env == "production"
  DataMapper.setup(:default, ENV["DATABASE_URL"])
  DataMapper.finalize
  DataMapper.auto_upgrade!
else
  DataMapper.setup(:default, "postgres://localhost/bookmark_manager_#{env}")
  DataMapper.finalize
  DataMapper.auto_upgrade!
end