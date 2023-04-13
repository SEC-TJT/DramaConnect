# frozen_string_literal: true

require 'json'
require 'sequel'

module DramaConnect
  # Models for a drama
  class Drama < Sequel::Model
    many_to_one :dramalist

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
              picture:,
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
<<<<<<< HEAD
=======

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(DramaConnect::STORE_DIR) unless Dir.exist? DramaConnect::STORE_DIR
    end

    # Stores Drama in file store
    def save
      File.write("#{DramaConnect::STORE_DIR}/#{id}.txt", to_json)
    end

    # Query method to find one Drama
    def self.find(find_id)
      document_file = File.read("#{DramaConnect::STORE_DIR}/#{find_id}.txt")
      Drama.new JSON.parse(document_file)
    end

    # Query method to retrieve index of all Drama
    def self.all
      Dir.glob("#{DramaConnect::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(DramaConnect::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
>>>>>>> origin/main
  end
end
