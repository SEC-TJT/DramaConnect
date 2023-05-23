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
        @account.add_owned_project(DATA[:dramalists][0])
        @account.add_owned_project(DATA[:dramalists][1])
      end
      it 'HAPPY: should get list for authorized account' do
        auth = DramaConnect::AuthenticateAccount.call(
          username: @account_data['username'],
          password: @account_data['password']
        )
        header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
        get 'api/v1/dramaList'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end
      it 'BAD: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/dramaList'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end
  end

  # it 'HAPPY: should be able to get list of all drama lists' do
  #   DramaConnect::Dramalist.create(DATA[:dramalists][0]).save
  #   DramaConnect::Dramalist.create(DATA[:dramalists][1]).save
  #   get 'api/v1/dramaList'
  #   _(last_response.status).must_equal 200

  #   result = JSON.parse last_response.body
  #   _(result['data'].count).must_equal 2
  # end

  it 'HAPPY: should be able to get details of a single dramaList' do
    existing_list = DATA[:dramalists][1]
    DramaConnect::Dramalist.create(existing_list).save
    id = DramaConnect::Dramalist.first.id

    get "/api/v1/dramaList/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['attributes']['id']).must_equal id
    _(result['attributes']['name']).must_equal existing_list['name']
  end

  it 'SAD: should return error if unknown drama_list requested' do
    get '/api/v1/dramaList/sad'

    _(last_response.status).must_equal 404
  end
  it 'SECURITY: should prevent basic SQL injection targeting IDs' do
    existing_list1 = DATA[:dramalists][0]
    existing_list2 = DATA[:dramalists][1]
    DramaConnect::Dramalist.create(existing_list1)
    DramaConnect::Dramalist.create(existing_list2)
    get 'api/v1/dramaList/2%20or%20id%3E0'

    # deliberately not reporting error -- don't give attacker information
    _(last_response.status).must_equal 404
    _(last_response.body['data']).must_be_nil
  end
  describe 'Creating New Drama List' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @drama_list_data = DATA[:dramalists][1]
    end
    it 'HAPPY: should be able to create new drama_lists' do
      # existing_list = DATA[:drama_lists][1]
      # req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/dramaList', @drama_list_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      created_db = DramaConnect::Dramalist.first(id: created['id'])

      _(created['id']).must_equal created_db.id
      _(created['name']).must_equal @drama_list_data['name']
    end
    it 'SECURITY: should not create Drama List with mass assignment' do
      bad_data = @drama_list_data.clone
      bad_data['created_time'] = '1900-01-01'
      post 'api/v1/dramaList', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end

# old Drama List test

# describe 'Test Drama List Handling' do
#   include Rack::Test::Methods

#   before do
#     wipe_database
#   end

#   it 'HAPPY: should be able to get list of all drama lists' do
#     DramaConnect::Dramalist.create(DATA[:drama_lists][0]).save
#     DramaConnect::Dramalist.create(DATA[:drama_lists][1]).save
#     get 'api/v1/dramaList'
#     _(last_response.status).must_equal 200

#     result = JSON.parse last_response.body
#     _(result['data'].count).must_equal 2
#   end

#   it 'HAPPY: should be able to get details of a single dramaList' do
#     existing_list = DATA[:drama_lists][1]
#     DramaConnect::Dramalist.create(existing_list).save
#     id = DramaConnect::Dramalist.first.id

#     get "/api/v1/dramaList/#{id}"
#     _(last_response.status).must_equal 200

#     result = JSON.parse last_response.body
#     _(result['data']['attributes']['id']).must_equal id
#     _(result['data']['attributes']['name']).must_equal existing_list['name']
#   end

#   it 'SAD: should return error if unknown drama_list requested' do
#     get '/api/v1/dramaList/sad'

#     _(last_response.status).must_equal 404
#   end

#   it 'HAPPY: should be able to create new drama_lists' do
#     existing_list = DATA[:drama_lists][1]

#     req_header = { 'CONTENT_TYPE' => 'application/json' }
#     post 'api/v1/dramaList', existing_list.to_json, req_header
#     _(last_response.status).must_equal 201
#     _(last_response.header['Location'].size).must_be :>, 0

#     created = JSON.parse(last_response.body)['data']['data']['attributes']
#     created_db = DramaConnect::Dramalist.first(id: created['id'])

#     _(created['id']).must_equal created_db.id
#     _(created['name']).must_equal created_db.name
#   end
# end
