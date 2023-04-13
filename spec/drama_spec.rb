# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test DramaConnect Web API' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Handle dramas' do
    it 'HAPPY: should be able to create and get list of all dramas' do
      DATA[:dramas].each do |drama|
        DramaConnect::Drama.create(drama)
      end

      get 'api/v1/drama'
      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 6
    end

    it 'HAPPY: should be able to get details of a single drama' do
      dra_data = DATA[:dramas][1]
      dra = DramaConnect::Drama.create(dra_data)

      get "/api/v1/drama/#{dra.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data']['attributes']['id']).must_equal dra.id
      _(result['data']['attributes']['name']).must_equal dra_data['name']
    end

    it 'SAD: should return error if unknown drama requested' do
      get '/api/v1/drama/foobar'

      _(last_response.status).must_equal 404
    end
  end
end
