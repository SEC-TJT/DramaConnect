# frozen_string_literal: true
require 'simplecov'
SimpleCov.start

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

def authenticate(account_data)
  DramaConnect::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  auth = authenticate(account_data)

  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)

  token = AuthToken.new(auth[:attributes][:auth_token])
  account = token.payload['attributes']
  { account: DramaConnect::Account.first(username: account['username']),
    scope: AuthScope.new(token.scope) }
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:dramas] = YAML.safe_load File.read('app/db/seeds/drama_seeds.yml')
DATA[:dramalists] = YAML.safe_load File.read('app/db/seeds/dramalist_seeds.yml')
DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/account_seeds.yml')
DATA[:accounts_modified] = YAML.safe_load File.read('app/db/seeds/account_modified_seeds.yml')

## SSO fixtures
GH_ACCOUNT_RESPONSE = YAML.load(
  File.read('spec/fixtures/github_token_response.yml')
)
GOOD_GH_ACCESS_TOKEN = GH_ACCOUNT_RESPONSE.keys.first
SSO_ACCOUNT = YAML.load(File.read('spec/fixtures/sso_account.yml'))
