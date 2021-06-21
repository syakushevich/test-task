require "active_record"

db_config = YAML.load(File.read(File.join("config", "database.yml")))

ActiveRecord::Base.establish_connection(db_config[ENV["APP_ENV"]])
