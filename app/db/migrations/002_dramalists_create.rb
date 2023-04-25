# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:dramalists) do
      uuid :id, primary_key: true

      String :name_secure, unique: true, null: false
      String :description_secure, unique: true

      DateTime :created_date
      DateTime :updated_date
    end
  end
end