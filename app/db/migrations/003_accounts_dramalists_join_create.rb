# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(visitor_id: :accounts, dramalist_id: { table: :dramalists, type: :uuid })
  end
end
