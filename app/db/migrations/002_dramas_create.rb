# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:dramas) do
      primary_key :id
      foreign_key :drama_list_id, table: :drama_lists

      String :name, null: false
      Float :rate, null: false
      String :review, null: false
      String :type, null: false
      String :category, null: false
      String :creator_id, null: false
      String :creator_name, null: false
      String :picture_url
      String :year
      String :link

      DateTime :created_at
      DateTime :updated_at

      unique %i[drama_list_id creator_id name]
    end
  end
end
