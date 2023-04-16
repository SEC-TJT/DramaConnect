# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'sequel'
require './app/lib/secure_db'

module DramaConnect
  # Configuration for the API
  class Api < Roda
    plugin :environments

    # rubocop:disable Lint/ConstantDefinitionInBlock
    configure do
      # load config secrets into local environment variables (ENV)
      Figaro.application = Figaro::Application.new(
        environment: environment, # rubocop:disable Style/HashSyntax
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load
      def self.config = Figaro.env

      # Database Setup
      db_url = ENV.delete('DATABASE_URL')
      DB = Sequel.connect("#{db_url}?encoding=utf8")
      def self.DB = DB # rubocop:disable Naming/MethodName

      # Load crypto keys
      SecureDB.setup(ENV.delete('DB_KEY'))
    end  

    configure :development, :test do
      require 'pry'
    end
  end
end
