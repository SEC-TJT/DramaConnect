# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/drama'

module DramaConnect
  # Web controller for DramaConnect API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Drama.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'DramaConnectAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'dramas' do
            # GET api/v1/dramas/{ID}
            routing.get String do |id|
              response.status = 200
              Drama.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Drama not found' }.to_json
            end

            # GET api/v1/dramas
            routing.get do
              response.status = 200
              output = { drama_ids: Drama.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/dramas
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_doc = Drama.new(new_data)

              if new_doc.save
                response.status = 201
                { message: 'Drama saved', id: new_doc.id }.to_json
              else
                routing.halt 400, { message: 'Could not save the drama' }.to_json
              end
            end
          end
        end
      end
    end
  end
end
