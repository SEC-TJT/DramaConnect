# frozen_string_literal: true

require 'roda'
require_relative './app'

module DramaConnect
  # Web controller for DramaConnect API
  class Api < Roda
    route('dramaList') do |routing| # rubocop:disable Metrics/BlockLength
      @list_route = "#{@api_root}/dramaList"

      routing.on String do |list_id| # rubocop:disable Metrics/BlockLength
        routing.on 'drama' do # rubocop:disable Metrics/BlockLength
          # GET api/v1/dramaList/[list_id]/drama/[drama_id]
          routing.get String do |drama_id|
            drama = Drama.where(dramalist_id: list_id, id: drama_id).first
            drama ? drama.to_json : raise('Drama not found')
          rescue StandardError => e
            Api.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 404, { message: e.message }.to_json
          end

          # GET api/v1/dramaList/[list_id]/drama
          routing.get do
            output = { data: Dramalist.first(id: list_id).dramas }
            JSON.pretty_generate(output)
          rescue StandardError => e
            Api.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 404, message: 'Could not find dramas'
          end

          # POST api/v1/dramaList/[list_id]/drama
          routing.post do
            new_data = JSON.parse(routing.body.read)
            dra_list = Dramalist.first(id: list_id)
            puts new_data
            puts dra_list
            new_dra = dra_list.add_drama(new_data)
            raise 'Could not save drama' unless new_dra

            response.status = 201
            response['Location'] = "#{@api_route}/drama/#{new_dra.id}"
            { message: 'Drama saved', data: new_dra }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            routing.halt 500, { message: e.message }.to_json
          end
        end

        # GET api/v1/dramaList/[ID]
        routing.get do
          dra_list = Dramalist.first(id: list_id)
          dra_list ? dra_list.to_json : raise('Dramalist not found')
        rescue StandardError => e
          Api.logger.error "UNKOWN ERROR: #{e.message}"
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # GET api/v1/dramaList
      routing.get do
        account = Account.first(username: @auth_account['username'])

        #  add data to test account
        # DATA = {}
        # DATA[:dramalists] = YAML.safe_load File.read('app/db/seeds/dramalist_seeds.yml')
        # DATA[:accounts] = YAML.safe_load File.read('app/db/seeds/account_seeds.yml')
        # account.add_owned_dramalist(DATA[:dramalists][0])
        # account.add_owned_dramalist(DATA[:dramalists][1])
        # finsih add test data

        dramalists = account.dramalists
        JSON.pretty_generate(data: dramalists)
        # output = { data: Dramalist.all }
        # JSON.pretty_generate(output)
      rescue StandardError => e
        Api.logger.error "UNKOWN ERROR: #{e.message}"
        routing.halt 403, { message: 'Could not find any dramaList' }.to_json
      end

      # POST api/v1/dramaList
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_dra_list = Dramalist.new(new_data)
        raise('Could not save drama_list') unless new_dra_list.save

        response.status = 201
        response['Location'] = "#{@list_route}/#{new_dra_list.id}"
        { message: 'Dramalist saved', data: new_dra_list }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Attributes' }.to_json
      rescue StandardError => e
        Api.logger.error "UNKOWN ERROR: #{e.message}"
        routing.halt 500, { message: 'Unknown server error' }.to_json
      end
    end
  end
end
