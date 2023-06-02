# frozen_string_literal: true

require './app/controllers/helpers.rb'
include DramaConnect::SecureRequestHelpers

Sequel.seed(:development) do
  def run
    puts 'Seeding accounts, dramalists, dramas'
    create_accounts
    create_owned_dramalists
    create_dramas
    add_visitors
  end
end

require 'yaml'
DIR = File.dirname(__FILE__)
ACCOUNTS_INFO = YAML.load_file("#{DIR}/accounts_seed.yml")
OWNER_INFO = YAML.load_file("#{DIR}/owners_dramalists.yml")
LIST_INFO = YAML.load_file("#{DIR}/dramalist_seed.yml")
DRAMA_INFO = YAML.load_file("#{DIR}/drama_seeds.yml")
VISITOR_INFO = YAML.load_file("#{DIR}/dramalists_visitors.yml")

def create_accounts
  ACCOUNTS_INFO.each do |account_info|
    DramaConnect::Account.create(account_info)
  end
end

def create_owned_dramalists
  OWNER_INFO.each do |owner|
    account = DramaConnect::Account.first(username: owner['username'])
    owner['list_name'].each do |list_name|
      list_data = LIST_INFO.find { |list| list['name'] == list_name }
      account.add_owned_dramalist(list_data)
    end
  end
end

def create_dramas
  dra_info_each = DRAMA_INFO.each
  dramalists_cycle = DramaConnect::Dramalist.all.cycle
  loop do
    dra_info = dra_info_each.next
    dramalist = dramalists_cycle.next
    auth_token = AuthToken.create(dramalist.owner)
    auth = scoped_auth(auth_token)
    DramaConnect::CreateDrama.call(
      auth: auth, dramalist:, drama_data: dra_info
    )
  end
end

def add_visitors
  visitor_info = VISITOR_INFO
  visitor_info.each do |visitor|
    list = DramaConnect::Dramalist.first(name: visitor['list_name'])

    auth_token = AuthToken.create(list.owner)
    auth = scoped_auth(auth_token)

    visitor['visitor_email'].each do |email|
      account = list.owner
      DramaConnect::AddVisitor.call(
        account:, dramalist: list, visitor_email: email
      )
    end
  end
end
