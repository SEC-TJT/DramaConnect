# frozen_string_literal: true

require 'json'
require 'sequel'

module DramaConnect
  # models for DramaList
  class Dramalist < Sequel::Model
    one_to_many :dramas
    
    plugin :uuid, field: :id
    plugin :association_dependencies, dramas: :destroy
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :description

    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'dramalist',
            attributes: {
              id:,
              name:,
              description:,
            }
          }
        },
        options
      )
    end
  end
end
