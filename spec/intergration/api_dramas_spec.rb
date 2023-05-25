# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Drama Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = DramaConnect::Account.create(@account_data)
    @account.add_owned_dramalist(DATA[:dramalists][0])
    @account.add_owned_dramalist(DATA[:dramalists][1])
    DramaConnect::Account.create(@wrong_account_data)
    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting a single drama' do
    it 'HAPPY: should be able to get details of a single drama' do
      dra_data = DATA[:dramas][0]
      list = @account.dramalists.first
      dra = list.add_drama(dra_data)
      # req_drama = DramaConnect::Drama.first(id: dra.id)
      req_drama = DramaConnect::Drama.find(id: dra.id)
      req_dramalist = DramaConnect::Dramalist.first(id: list.id)
      puts DramaConnect::Drama.all[0].to_json
      puts dra.dramalist_id
      puts req_drama.dramalist_id
      puts dra.dramalist_id.class
      puts list.id.class

      # puts @req_dramalist.to_json
      # puts @req_dramalist.dramas.to_json
      # puts @req_dramalist.owner.to_json
      # puts @req_drama.to_json
      # puts @req_drama.dramalist == list
      # puts @req_drama.dramalist.owner == @account
      # puts dra.dramalist.owner
      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/dramas/#{dra.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal dra.id
      _(result['attributes']['name']).must_equal dra_data['name']
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      dra_data = DATA[:dramas][1]
      list = DramaConnect::Dramalist.first
      dra = list.add_drama(dra_data)
      get "/api/v1/drams/#{dra.id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      dra_data = DATA[:dramas][0]
      list = @account.dramalists.first
      dra = list.add_drama(dra_data)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/dramas/#{dra.id}"
      puts 'hi'
      puts last_response.body
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if drama does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/dramas/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating Dramas' do
    before do
      @list = DramaConnect::Dramalist.first
      @dra_data = DATA[:dramas][1]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/dramaList/#{@list.id}/dramas", @dra_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      dra = DramaConnect::Drama.first

      _(created['id']).must_equal dra.id
      _(created['name']).must_equal @dra_data['name']
      _(created['rate']).must_equal @dra_data['rate']
    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "api/v1/dramaList/#{@list.id}/dramas", @dra_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/dramaList/#{@list.id}/dramas", @dra_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @dra_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/dramaList/#{@list.id}/dramas", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
      _(data).must_be_nil
    end
  end
end
