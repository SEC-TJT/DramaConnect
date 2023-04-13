# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test DramaConnect Web API' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end

  describe 'Handle dramas' do
    it 'HAPPY: should be able to get list of all dramas' do
      DramaConnect::Drama.new(DATA[:drama][0]).save
      DramaConnect::Drama.new(DATA[:drama][1]).save
      DramaConnect::Drama.new(DATA[:drama][2]).save

      get 'api/v1/dramas'
      result = JSON.parse last_response.body
      _(result['drama_ids'].count).must_equal 3
    end

    it 'HAPPY: should be able to get details of a single drama' do
      DramaConnect::Drama.new(DATA[:drama][2]).save
      id = Dir.glob("#{DramaConnect::STORE_DIR}/*.txt").first.split(%r{[/.]})[3]

      get "/api/v1/dramas/#{id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 200
      _(result['id']).must_equal id
    end

    it 'SAD: should return error if unknown drama requested' do
      get '/api/v1/dramas/foobar'

      _(last_response.status).must_equal 404
    end

    it 'HAPPY: should be able to create new dramas' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/dramas', DATA[:drama][2].to_json, req_header

      _(last_response.status).must_equal 201
    end
  end
end