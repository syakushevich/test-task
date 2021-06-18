# frozen_string_literal: true

require "bundler/setup"
require "active_record"

ENV["APP_ENV"] ||= "development"

include ActiveRecord::Tasks

db_dir = File.expand_path('../db', __FILE__)
config_dir = File.expand_path('../config', __FILE__)

DatabaseTasks.env = ENV["APP_ENV"]
DatabaseTasks.db_dir = db_dir
DatabaseTasks.database_configuration = YAML.load(File.read(File.join(config_dir, "database.yml")))
DatabaseTasks.migrations_paths = File.join(db_dir, "migrate")

task :environment do
  ActiveRecord::Base.configurations = DatabaseTasks.database_configuration
  ActiveRecord::Migrator.migrations_paths = ActiveRecord::Tasks::DatabaseTasks.migrations_paths
  ActiveRecord::Base.establish_connection DatabaseTasks.env.to_sym
end

db_namespace = namespace :db do
  desc "Creates the database from config/database.yml APP_ENV."
  task create: :environment do
    ActiveRecord::Tasks::DatabaseTasks.create_current
  end

  desc "Drops the database from config/database.yml"
  task drop: :environment do
    ActiveRecord::Tasks::DatabaseTasks.drop_current
  end

  desc "Migrate the database (options: VERSION=x, VERBOSE=false, SCOPE=blog)."
  task migrate: :environment do
    original_db_config = ActiveRecord::Base.connection_db_config
    ActiveRecord::Base.configurations.configs_for(env_name: ActiveRecord::Tasks::DatabaseTasks.env).each do |db_config|
      ActiveRecord::Base.establish_connection(db_config)
      ActiveRecord::Tasks::DatabaseTasks.migrate
    end
    db_namespace["schema:dump"].invoke
  ensure
    ActiveRecord::Base.establish_connection(original_db_config)
  end

  namespace :schema do
    desc "Creates a database schema file"
    task dump: :environment do
      ActiveRecord::Base.configurations.configs_for(env_name: ActiveRecord::Tasks::DatabaseTasks.env).each do |db_config|
        ActiveRecord::Base.establish_connection(db_config)
        ActiveRecord::Tasks::DatabaseTasks.dump_schema(db_config)
      end

      db_namespace["schema:dump"].reenable
    end
  end
end
