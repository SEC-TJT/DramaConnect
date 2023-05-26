# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  # app.DB[:dramas].delete
  # app.DB[:dramalists].delete
  DramaConnect::Drama.map(&:destroy)
  DramaConnect::Dramalist.map(&:destroy)
  DramaConnect::Account.map(&:destroy)
end

def auth_header(account_data)
  auth = DramaConnect::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )

  "Bearer #{auth[:attributes][:auth_token]}"
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:dramas] = YAML.safe_load File.read('app/db/seeds/drama_seeds.yml')
DATA[:dramalists] = YAML.safe_load File.read('app/db/seeds/dramalist_seeds.yml')
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/account_seeds.yml')
