# frozen_string_literal: true

require 'json'
require 'sequel'

module DramaConnect
  # models for DramaList
  class Dramalist < Sequel::Model
    one_to_many :dramas
    plugin :association_dependencies, dramas: :destroy
    plugin :timestamps

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
