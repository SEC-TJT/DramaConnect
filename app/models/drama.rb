# frozen_string_literal: true

require 'json'
require 'sequel'

module DramaConnect
  # Models for a drama
  class Drama < Sequel::Model
    many_to_many :dramalist

    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :rate, :review, :type, :category, :creator_id, :creator_name, :picture_url, :year, :link, :updated_date
    
    # Secure getters and setters
    def name
      SecureDB.decrypt(name_secure)
    end

    def name=(plaintext)
      self.name_secure = SecureDB.encrypt(plaintext)
    end

    def rate
      SecureDB.decrypt(rate_secure)
    end

    def rate=(plaintext)
      self.content_secure = SecureDB.encrypt(plaintext)
    end

    def review
      SecureDB.decrypt(review_secure)
    end

    def review=(plaintext)
      self.review_secure = SecureDB.encrypt(plaintext)
    end

    def picture_url
      SecureDB.decrypt(picture_url_secure)
    end

    def picture_url=(plaintext)
      self.picture_url_secure = SecureDB.encrypt(plaintext)
    end

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
