# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:dramas) do
      uuid :id, primary_key: true
      foreign_key :dramalist_id, table: :dramalists, type: :uuid

      String :name_secure, null: false
      String :rate_secure, null: false
      String :review_secure, null: false
      String :type, null: false
      String :category, null: false
      String :picture_url_secure
      String :year, null: false
      String :link, null: false

      DateTime :created_date
      DateTime :updated_date

      unique %i[dramalist_id name_secure]
    end
  end
end
