# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Drama Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    # puts DATA[:drama_lists]
    DATA[:dramalists].each do |drama_list|
      # puts drama_list
      DramaConnect::Dramalist.create(drama_list).save
    end
  end

  it 'HAPPY: should be able to get list of all dramas' do
    drama_list = DramaConnect::Dramalist.first
    DATA[:dramas].each do |drama|
      drama_list.add_drama(drama)
    end
     # GET api/v1/dramaList/[list_id]/dramas
    get "api/v1/dramaList/#{drama_list.id}/drama"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 6
  end

  it 'HAPPY: should be able to get details of a single drama' do
    drama_data = DATA[:dramas][1]
    drama_list = DramaConnect::Dramalist.first
    drama = drama_list.add_drama(drama_data)

    # GET api/v1/drama/[drama_id]
    # print drama.id
    get "/api/v1/drama/#{drama.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    # print result['data']['attributes']
    _(result['data']['attributes']['review']).must_equal drama.review
    _(result['data']['attributes']['name']).must_equal drama_data['name']
  end
  it 'SAD: should return error if unknown drama requested' do
     # GET api/v1/dramas/[drama_id]
    get "/api/v1/dramas/baddrama"

    _(last_response.status).must_equal 404
  end
  describe 'Creating Dramas' do
    before do
      @drama_list = DramaConnect::Dramalist.first
      @drama_data = DATA[:dramas][1]
      @drama = @drama_list.add_drama(@drama_data)
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new dramas' do
      # req_header = { 'CONTENT_TYPE' => 'application/json' }
      # api/v1/dramaList/[ID]/drama
      print @drama.id
      post "api/v1/dramaList/#{@drama_list.id}/drama/#{@drama.id}",
           @drama_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      drama = DramaConnect::Drama.first

      _(created['id']).must_equal drama.id
      _(created['name']).must_equal @drama_data['name']
      _(created['review']).must_equal @drama_data['review']
    end

    it 'SECURITY: should not create dramas with mass assignment' do
      bad_data = @drama_data.clone
      bad_data['created_date'] = '1900-01-01'
      post "api/v1/drama",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end


# old test for reference

# describe 'Test DramaConnect Web API' do
#   include Rack::Test::Methods

#   before do
#     wipe_database
#   end

#   describe 'Handle dramas' do
#     it 'HAPPY: should be able to create and get list of all dramas' do
#       DATA[:dramas].each do |drama|
#         DramaConnect::Drama.create(drama)
#       end

#       get 'api/v1/drama'
#       result = JSON.parse last_response.body

#       _(result['data'].count).must_equal 6
#     end

#     it 'HAPPY: should be able to get details of a single drama' do
#       dra_data = DATA[:dramas][1]
#       dra = DramaConnect::Drama.create(dra_data)

#       get "/api/v1/drama/#{dra.id}"
#       _(last_response.status).must_equal 200

#       result = JSON.parse last_response.body
#       _(result['data']['attributes']['id']).must_equal dra.id
#       _(result['data']['attributes']['name']).must_equal dra_data['name']
#     end

#     it 'SAD: should return error if unknown drama requested' do
#       get '/api/v1/drama/foobar'

#       _(last_response.status).must_equal 404
#     end
#   end
# end
