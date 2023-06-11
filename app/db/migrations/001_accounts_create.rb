# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:accounts) do
      primary_key :id

      String :username, null: false, unique: true
      String :name, null: false
      String :email, null: false, unique: true
      String :password_digest
      String :avatar
      String :description
      DateTime :created_date
      DateTime :updated_date
    end
  end
end
