# frozen_string_literal: true

require_relative './app'

module  DramaConnect
  # Web controller for DramaConnect API
  class Api < Roda
    route('dramas') do |routing|
      routing.halt 403, { message: 'Not authorized' }.to_json unless @auth_account

      @dra_route = "#{@api_root}/dramas"

      # GET api/v1/dramas/[dra_id]
      routing.on String do |dra_id|
        @req_drama = Drama.first(id: dra_id)

        routing.get do
          drama = GetDramaQuery.call(
            auth: @auth, drama: @req_drama
          )

          { data: drama }.to_json
        rescue GetDramaQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetDramaQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.warn "Drama Error: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
