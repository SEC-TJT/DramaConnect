# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module DramaConnect
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_dramalists, class: :'DramaConnect::Dramalist', key: :owner_id
    many_to_many :visiting,
                 class: :'DramaConnect::Dramalist',
                 join_table: :accounts_dramalists,
                 left_key: :visitor_id, right_key: :dramalist_id

    plugin :association_dependencies,
           owned_dramalists: :destroy,
           visiting: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def dramalists
      owned_dramalists + visiting
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = DramaConnect::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          attributes: {
            username:,
            email:
          }
        }, options
      )
    end
  end
end
