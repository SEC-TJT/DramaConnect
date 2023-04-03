# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module DramaConnect
  STORE_DIR = 'app/db/store'

  # Holds a full drama
  class Drama
    # Create drama by passing in hash of attributes
    def initialize(new_drama)
      @id = new_drama['id'] || new_id
      @name = new_drama['name']
      @rate = new_drama['rate']
      @review = new_drama['review']
      @type = new_drama['type']
      @category = new_drama['category']
      @creator_id = new_drama['creator_id']
      @creator_name = new_drama['creator_name']
      @picture = new_drama['picture']
      @year = new_drama['year']
      @created_date = new_drama['created_date']
      @updated_date = new_drama['updated_date']
      @link = new_drama['link']
    end

    attr_reader :id, :name, :category, :creator_id, :creator_name, :picture, :year, :created_date, :updated_date,
                :link, :rate, :review, :type

    def to_json(options = {})
      JSON(
        {
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
        },
        options
      )
    end

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
      Document.new JSON.parse(document_file)
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
  end
end
