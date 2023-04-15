# frozen_string_literal: true
# require 'logger'
require 'roda'
require 'json'

module DramaConnect
  # Web controller for DramaConnect API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'DramaConnectAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'dramaList' do
          @list_route = "#{@api_root}/dramaList"

          routing.on String do |list_id|
            routing.on 'drama' do
              # GET api/v1/dramaList/[list_id]/dramas
              routing.get do
                output = { data: Dramalist.first(id: list_id).dramas }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find dramas'
              end

              # POST api/v1/dramaList/[ID]/dramas
              routing.post String do |drama_id|
                # new_data = JSON.parse(routing.body.read)
                # drama_id = new_data.drama_id
                dra_list = Dramalist.first(id: list_id)
                new_dra = Drama.first(id: drama_id)

                dra_list.add_drama(new_dra)

                if new_dra
                  response.status = 201
                  response['Location'] = "#{@api_route}/drama/#{new_dra.id}"
                  { message: 'Drama saved', data: new_dra }.to_json
                else
                  routing.halt 400, 'Could not save drama'
                end

              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/dramaList/[ID]
            routing.get do
              dra_list = Dramalist.first(id: list_id)
              dra_list ? dra_list.to_json : raise('Dramalist not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/dramaList
          routing.get do
            output = { data: Dramalist.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find dramaList' }.to_json
          end

          # POST api/v1/dramaList
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_dra_list = Dramalist.new(new_data)
            raise('Could not save drama_list') unless new_dra_list.save

            response.status = 201
            response['Location'] = "#{@list_route}/#{new_dra_list.id}"
            { message: 'Dramalist saved', data: new_dra_list }.to_json
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end
        routing.on 'drama' do
          # GET api/v1/dramas/[drama_id]
          routing.get String do |drama_id|
            drama = Drama.first(id: drama_id)
            drama ? drama.to_json : raise('Drama not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # GET api/v1/dramas
          routing.get do
            output = { data: Drama.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, message: 'Could not find dramas'
          end

          # POST api/v1/dramas
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_dra = Drama.new(new_data)
            raise('Could not save drama ') unless new_dra.save
            response.status = 201
            response['Location'] = "#{@api_route}/drama/#{new_dra.id}"
            { message: 'Drama saved', data: new_dra }.to_json
          rescue StandardError
            routing.halt 500, { message: 'Database error' }.to_json
          end
        end
      end
    end
  end
end
