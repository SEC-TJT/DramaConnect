# frozen_string_literal: true

require 'json'
require 'sequel'

module DramaConnect
  # Models for a drama
  class Drama < Sequel::Model
    many_to_one :dramalist, class: :'DramaConnect::Dramalist'

    plugin :uuid, field: :id
    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :name, :rate, :review, :type, :category, :picture_url, :year,
                        :link, :updated_date

    # Secure getters and setters
    def name
      SecureDB.decrypt(name_secure)
    end

    def name=(plaintext)
      self.name_secure = SecureDB.encrypt(plaintext)
    end

    def rate
      SecureDB.decrypt(rate_secure).to_f
    end

    def rate=(plaintext)
      self.rate_secure = SecureDB.encrypt(plaintext.to_s)
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
    def to_json(options = {}) # rubocop:disable Metrics/MethodLength
      JSON(
        {
          type: 'drama',
          attributes: {
            id:,
            type:,
            name:,
            category:,
            picture_url:,
            year:,
            created_date:,
            updated_date:,
            link:,
            rate:,
            review:
          },
          include: {
            dramalist:
          }
        },
        options
      )
    end
  end
end
