# frozen_string_literal: true

require 'json'
require 'sequel'

module DramaConnect
  # models for DramaList
  class Dramalist < Sequel::Model
    one_to_many :dramas, class: :'DramaConnect::Drama', key: :dramalist_id

    many_to_one :owner, class: :'DramaConnect::Account'
    many_to_many :visitors,
                 class: :'DramaConnect::Account',
                 join_table: :accounts_dramalists,
                 left_key: :dramalist_id, right_key: :visitor_id

    plugin :uuid, field: :id
    plugin :association_dependencies, dramas: :destroy, visitors: :nullify
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :description, :updated_date

    # Secure getters and setters
    def name
      SecureDB.decrypt(name_secure)
    end

    def name=(plaintext)
      self.name_secure = SecureDB.encrypt(plaintext)
    end

    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    def to_h
      {
        type: 'dramalist',
        attributes: {
          id:,
          name:,
          description:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner:,
          visitors:,
          dramas:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
