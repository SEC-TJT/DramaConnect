# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:drama_lists) do
      primary_key :id

      String :name, unique: true, null: false
      String :description, unique: true

      DateTime :created_at
      DateTime :updated_at
    end
  end
end