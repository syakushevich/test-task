# frozen_string_literal: true

require "bundler"

Bundler.require(:default, ENV["APP_ENV"])

Dir[File.expand_path("../config/initializers/*.rb", __dir__)].sort.each do |initializer|
  require initializer
end

loading_paths = ["lib"]

loader = Zeitwerk::Loader.new
loader.inflector.inflect "dto" => "DTO"

loading_paths.each { |path| loader.push_dir(path) }

if ENV["APP_ENV"] == "production"
  loader.setup
  Zeitwerk::Loader.eager_load_all
else
  loader.enable_reloading
  loader.setup

  if ENV["APP_ENV"] == "development"
    listener = Listen.to(*loading_paths) { loader.reload }
    listener.start
  end
end
