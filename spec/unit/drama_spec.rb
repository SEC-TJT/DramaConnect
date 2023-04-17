# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Drama Handling' do
  before do
    wipe_database

    DATA[:dramalists].each do |drama_list|
      DramaConnect::Dramalist.create(drama_list)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    drama_data = DATA[:dramas][1]
    drama_list = DramaConnect::Dramalist.first
    new_drama = drama_list.add_drama(drama_data)

    drama = DramaConnect::Drama.find(id: new_drama.id)
    _(drama.name).must_equal drama_data['name']
    _(drama.rate).must_equal drama_data['rate']
  end

  it 'SECURITY: should not use deterministic integers' do
    drama_data = DATA[:dramas][1]
    drama_list = DramaConnect::Dramalist.first
    new_drama = drama_list.add_drama(drama_data)

    _(new_drama.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    drama_data = DATA[:dramas][1]
    drama_list = DramaConnect::Dramalist.first
    new_drama = drama_list.add_drama(drama_data)
    stored_drama = app.DB[:dramas].first

    _(stored_drama[:name_secure]).wont_equal new_drama.name
    _(stored_drama[:review_secure]).wont_equal new_drama.review
  end
end
