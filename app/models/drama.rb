# frozen_string_literal: true

require 'json'
require 'sequel'

module DramaConnect
  # Models for a drama
  class Drama < Sequel::Model
    many_to_many :dramalist

    plugin :timestamps
    # Create drama by passing in hash of attributes
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'drama',
            attributes: {
              type:,
              id:,
              name:,
              category:,
              creator_id:,
              creator_name:,
              picture_url:,
              year:,
              created_date:,
              updated_date:,
              link:,
              rate:,
              review:
            }
          }
        },
        options
      )
    end
  end
end
