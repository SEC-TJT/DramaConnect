# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:dramalists) do
      primary_key :id

      String :name, unique: true, null: false
      String :description, unique: true

      DateTime :created_date
      DateTime :updated_date
    end
  end
end