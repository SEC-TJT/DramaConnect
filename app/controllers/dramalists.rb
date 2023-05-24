# frozen_string_literal: true

require_relative './app'

module DramaConnect
  # Web controller for DramaConnect API
  class Api < Roda
    route('dramaList') do |routing| # rubocop:disable Metrics/BlockLength
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @list_route = "#{@api_root}/dramaList"

      routing.on String do |list_id| # rubocop:disable Metrics/BlockLength
        @req_dramalist = Dramalist.first(id: list_id)
        # GET api/v1/dramaLists/[ID]
        routing.get do
          dramalist = GetDramalistQuery.call(
            account: @auth_account, dramalist: @req_dramalist
          )

          { data: dramalist }.to_json
        rescue GetDramalistQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetDramalistQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND DRAMALIST ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        routing.on('dramas') do
          # POST api/v1/dramaList/[list_id]/dramas
          routing.post do
            # new_data = JSON.parse(routing.body.read)
            # dra_list = Dramalist.first(id: list_id)
            # puts new_data
            # puts dra_list
            # new_dra = dra_list.add_drama(new_data)
            # raise 'Could not save drama' unless new_dra
            new_drama = CreateDrama.call(
              account: @auth_account,
              dramalist: @req_dramalist,
              drama_data: JSON.parse(routing.body.read)
            )

            response.status = 201
            response['Location'] = "#{@dra_route}/#{new_dra.id}"
            { message: 'Drama saved', data: new_drama }.to_json
          rescue CreateDrama::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateDrama::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            Api.logger.warn "Could not create drama: #{e.message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('visitors') do # rubocop:disable Metrics/BlockLength
          # PUT api/v1/dramaList/[list_id]/visitors
          routing.put do
            req_data = JSON.parse(routing.body.read)

            visitor = AddVisitor.call(
              account: @auth_account,
              dramalist: @req_dramalist,
              visitor_email: req_data['email']
            )

            { data: visitor }.to_json
          rescue AddVisitor::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/dramaList/[list_id]/visitors
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            visitor = RemoveVisitor.call(
              req_username: @auth_account.username,
              visitor_email: req_data['email'],
              dramalist_id: list_id
            )

            { message: "#{visitor.username} removed from dramalist",
              data: visitor }.to_json
          rescue RemoveVisitor::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      routing.is do
        # GET api/v1/dramaList
        routing.get do
          dramalists = DramalistPolicy::AccountScope.new(@auth_account).viewable
          JSON.pretty_generate(data: dramalists)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any dramalists' }.to_json
        end

        # POST api/v1/dramaList
        routing.post do
          new_data = JSON.parse(routing.body.read)
          new_list = @auth_account.add_owned_dramalist(new_data)

          response.status = 201
          response['Location'] = "#{@list_route}/#{new_list.id}"
          { message: 'Dramalist saved', data: new_list }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue StandardError
          Api.logger.error "Unknown error: #{e.message}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
