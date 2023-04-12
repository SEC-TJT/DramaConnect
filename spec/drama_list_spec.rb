# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Drama List Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all drama lists' do
    get 'api/v1/dramaList'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single dramaList' do
    existing_list = DATA[:drama_lists][1]
    DramaConnect::DramaList.create(existing_list).save
    id = DramaConnect::DramaList.first.id

    get "/api/v1/dramaList/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['name']).must_equal existing_list['name']
  end

  it 'SAD: should return error if unknown drama_list requested' do
    get '/api/v1/dramaList/sad'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new drama_lists' do
    existing_list = DATA[:drama_lists][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/dramaList', existing_list.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    list_db = DramaConnect::DramaList.first

    _(created['id']).must_equal list_db.id
    _(created['name']).must_equal list_db['name']
  end
end
