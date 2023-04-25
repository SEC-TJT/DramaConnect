# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(vistor_id: :accounts, dramalist_id: :dramalists)
  end
end
