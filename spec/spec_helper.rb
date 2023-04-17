# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:dramas].delete
  app.DB[:dramalists].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:dramas] = YAML.safe_load File.read('app/db/seeds/drama_seeds.yml')
DATA[:dramalists] = YAML.safe_load File.read('app/db/seeds/dramalist_seeds.yml')
