# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Drama Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:dramalists].each do |dramalist_data|
      DramaConnect::Dramalist.create(dramalist_data)
    end
  end

  it 'HAPPY: should be able to get list of all dramas' do
    dra_list = DramaConnect::Dramalist.first
    DATA[:dramalists].each do |drama|
      dra_list.add_drama(drama)
    end

    get "api/v1/dramaList/#{dra_list.id}/drama"
    _(last_response.status).must_equal 200

    result = JSON.parse(last_response.body)['data']
    _(result.count).must_equal 4
    result.each do |doc|
      _(doc['type']).must_equal 'drama'
    end
  end

  it 'HAPPY: should be able to get details of a single drama' do
    dra_data = DATA[:dramas][1]
    dra_list = DramaConnect::Dramalist.first
    dra = dra_list.add_drama(dra_data)

    get "/api/v1/dramaList/#{dra_list.id}/drama/#{dra.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal dra.id
    _(result['data']['attributes']['name']).must_equal dra_data['name']
  end

  it 'SAD: should return error if unknown drama requested' do
    dra_list = DramaConnect::Dramalist.first
    get "/api/v1/drama/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating Dramas' do
    before do
      @dra_list = DramaConnect::Dramalist.first
      @dra_data = DATA[:dramas][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new dramas' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post "api/v1/dramaList/#{@dra_list.id}/drama",
           @dra_data.to_json, req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      dra = DramaConnect::Drama.first

      _(created['id']).must_equal dra.id
      _(created['name']).must_equal @dra_data['name']
      _(created['rate']).must_equal @dra_data['rate']
    end

    it 'SECURITY: should not create dramas with mass assignment' do
      bad_data = @dra_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/dramaList/#{@dra_list.id}/drama",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
