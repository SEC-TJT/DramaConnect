# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Drama List Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = DramaConnect::Account.create(@account_data)
    @wrong_account = DramaConnect::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end
  describe 'Getting DramaLists' do
    describe 'Getting lists of DramaLists' do
      before do
        @account.add_owned_dramalist(DATA[:dramalists][0])
        @account.add_owned_dramalist(DATA[:dramalists][1])
      end
      it 'HAPPY: should get list for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)
        get 'api/v1/dramaList'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'HAPPY: should delete list for authorized account' do
        drama_list = DramaConnect::Dramalist.first
        header 'AUTHORIZATION', auth_header(@account_data)
        delete "api/v1/dramaList/#{drama_list.id}"
        _(last_response.status).must_equal 200
      end

      it 'HAPPY: should update list for authorized account' do
        drama_list = DramaConnect::Dramalist.first
        update_dralist = DATA[:dramalists][1]
        header 'AUTHORIZATION', auth_header(@account_data)
        post "api/v1/dramaList/#{drama_list.id}/update", update_dralist.to_json
        _(last_response.status).must_equal 201
      end

      it 'BAD: should not process without authorization' do
        get 'api/v1/dramaList'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end
  end

  it 'HAPPY: should be able to get details of a single dramaList' do
    list = @account.add_owned_dramalist(DATA[:dramalists][0])

    header 'AUTHORIZATION', auth_header(@account_data)
    get "/api/v1/dramaList/#{list.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse(last_response.body)['data']
    _(result['attributes']['id']).must_equal list.id
    _(result['attributes']['name']).must_equal list.name
  end

  it 'SAD: should return error if unknown drama_list requested' do
    header 'AUTHORIZATION', auth_header(@account_data)
    get '/api/v1/dramaList/sad'

    _(last_response.status).must_equal 404
  end

  # it 'SECURITY: should prevent basic SQL injection targeting IDs' do
  #   existing_list1 = DATA[:dramalists][0]
  #   existing_list2 = DATA[:dramalists][1]
  #   DramaConnect::Dramalist.create(existing_list1)
  #   DramaConnect::Dramalist.create(existing_list2)
  it 'BAD AUTHORIZATION: should not get dramalist with wrong authorization' do
    list = @account.add_owned_dramalist(DATA[:dramalists][0])

    header 'AUTHORIZATION', auth_header(@wrong_account_data)
    get "/api/v1/dramaList/#{list.id}"
    _(last_response.status).must_equal 403

    result = JSON.parse last_response.body
    _(result['attributes']).must_be_nil
  end

  it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of id' do
    @account.add_owned_dramalist(DATA[:dramalists][0])
    @account.add_owned_dramalist(DATA[:dramalists][1])

    header 'AUTHORIZATION', auth_header(@account_data)
    get 'api/v1/dramaList/2%20or%20id%3E0'

    # deliberately not reporting detection -- don't give attacker information
    _(last_response.status).must_equal 404
    _(last_response.body['data']).must_be_nil
  end
  describe 'Creating New Drama List' do
    before do
      # @req_header = { 'CONTENT_TYPE' => 'application/json' }
      # @drama_list_data = DATA[:dramalists][1]
      @drama_list_data = DATA[:dramalists][0]
    end
    it 'HAPPY: should be able to create new drama_lists' do
      # existing_list = DATA[:drama_lists][1]
      # req_header = { 'CONTENT_TYPE' => 'application/json' }
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/dramaList', @drama_list_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      created_db = DramaConnect::Dramalist.first(id: created['id'])

      _(created['id']).must_equal created_db.id
      _(created['name']).must_equal @drama_list_data['name']
    end

    it 'SAD: should not create new dramalist without authorization' do
      post 'api/v1/dramaList', @drama_list_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'SECURITY: should not create Drama List with mass assignment' do
      bad_data = @drama_list_data.clone
      bad_data['created_time'] = '1900-01-01'
      # post 'api/v1/dramaList', bad_data.to_json, @req_header
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/dramaList', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
