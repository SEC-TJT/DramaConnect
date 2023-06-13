# frozen_string_literal: true

require_relative './app'

module DramaConnect
  # Web controller for DramaConnect API
  class Api < Roda
    route('dramaList') do |routing| # rubocop:disable Metrics/BlockLength
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @list_route = "#{@api_root}/dramaList"

      # GET api/v1/dramaList/[list_id]/dramas/[drama_id]
      routing.get String, 'dramas', String do |list_id, drama_id|
        @req_dramalist = Dramalist.first(id: list_id)
        @req_drama = Drama.first(id: drama_id)
        drama, policy = GetDramaQuery.call(
          auth: @auth, drama: @req_drama
        )
        puts 'try:', policy
        { data: drama, policy: }.to_json
      rescue GetDramaQuery::ForbiddenError => e
        routing.halt 403, { message: e.message }.to_json
      rescue GetDramaQuery::NotFoundError => e
        routing.halt 404, { message: e.message }.to_json
      rescue StandardError => e
        puts "FIND DRAMALIST ERROR: #{e.inspect}"
        routing.halt 500, { message: 'API server error' }.to_json
      end
      # Delete api/v1/dramaList/[list_id]/dramas/[drama_id]
      routing.delete String, 'dramas', String do |_list_id, drama_id|
        drama = RemoveDrama.call(
          auth: @auth,
          drama_id:
        )
        { message: "#{drama.name} removed from dramalist",
          data: drama }.to_json
      rescue RemoveDrama::ForbiddenError => e
        routing.halt 403, { message: e.message }.to_json
      rescue StandardError
        routing.halt 500, { message: 'API server error' }.to_json
      end

      routing.post String, 'dramas', String, 'update' do |_list_id, drama_id|
        data_drama = JSON.parse(routing.body.read)
        data_drama['updated_date'] = DateTime.now
        puts data_drama
        new_drama = UpdateDrama.call(
          auth: @auth,
          drama_id:,
          drama_data: data_drama
        )
        response.status = 201
        response['Location'] = "#{@dra_route}/#{new_drama.id}"
        { message: 'Drama saved', data: new_drama }.to_json
      rescue UpdateDrama::ForbiddenError => e
        routing.halt 403, { message: e.message }.to_json
      rescue UpdateDrama::IllegalRequestError => e
        routing.halt 400, { message: e.message }.to_json
      rescue StandardError => e
        Api.logger.warn "Could not create drama: #{e.message}"
        routing.halt 500, { message: 'API server error' }.to_json
      end
      # GET api/v1/dramaList/owned
      routing.on('owned') do
        routing.get do
          dramalists = DramalistPolicy::AccountScope.new(@auth_account).ownable
          puts JSON.pretty_generate(data: dramalists)
          JSON.pretty_generate(data: dramalists)
          # rescue StandardError
          #   routing.halt 403, { message: 'Could not find any dramalists' }.to_json
        end
      end

      # GET api/v1/dramaList/shared
      routing.get('shared') do
        puts 'sharing'
        dramalists = DramalistPolicy::AccountScope.new(@auth_account).shareable
        puts dramalists
        JSON.pretty_generate(data: dramalists)
      rescue StandardError
        routing.halt 403, { message: 'Could not find any dramalists' }.to_json
      end

      routing.on String do |list_id| # rubocop:disable Metrics/BlockLength
        @req_dramalist = Dramalist.first(id: list_id)
        # GET api/v1/dramaLists/[ID]
        routing.get do
          dramalist = GetDramalistQuery.call(
            auth: @auth, dramalist: @req_dramalist
          )
          puts dramalist
          { data: dramalist }.to_json
        rescue GetDramalistQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetDramalistQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND DRAMALIST ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        # PUT api/v1/dramaLists/[ID]/update
        routing.post('update') do
          data_dramalist = JSON.parse(routing.body.read)
          data_dramalist['updated_date'] = DateTime.now
          puts data_dramalist
          drama_list = UpdateDramalist.call(
            auth: @auth,
            list_id:,
            dramalist_data: data_dramalist
          )
          response.status = 201
          response['Location'] = "#{@dra_route}/#{drama_list.id}"
          { message: 'Dramalist updated', data: data_dramalist }.to_json
        rescue UpdateDrama::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue UpdateDrama::IllegalRequestError => e
          routing.halt 400, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.warn "Could not create drama: #{e.message}"
        end

        routing.on('dramas') do
          # POST api/v1/dramaList/[list_id]/dramas
          routing.post do
            data_drama = JSON.parse(routing.body.read)
            data_drama['created_date'] = DateTime.now
            data_drama['updated_date'] = DateTime.now
            new_drama = CreateDrama.call(
              auth: @auth,
              dramalist: @req_dramalist,
              drama_data: data_drama
            )
            response.status = 201

            response['Location'] = "#{@dra_route}/#{new_drama.id}"
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

        routing.on('visitors') do
          # PUT api/v1/dramaList/[list_id]/visitors
          routing.put do
            req_data = JSON.parse(routing.body.read)
            puts 'ttt'
            visitor = AddVisitor.call(
              auth: @auth,
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
            puts 'delete data', req_data
            visitor = RemoveVisitor.call(
              auth: @auth,
              visitor_email: req_data['email'],
              dramalist_id: list_id
            )

            { message: "#{visitor.username} removed from dramalist",
              data: visitor }.to_json
            # rescue RemoveVisitor::ForbiddenError => e
            #   routing.halt 403, { message: e.message }.to_json
            # rescue StandardError
            #   routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        # Delete api/v1/dramaLists/[ID]
        routing.delete do
          puts list_id
          list = RemoveDramalist.call(
            auth: @auth,
            dramalist_id: list_id
          )

          { message: "#{list.name} removed from dramalist",
            data: list }.to_json
        rescue RemoveDramalist::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          routing.halt 500, { message: 'API server error' }.to_json
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
          new_data['created_date'] = DateTime.now
          new_data['updated_date'] = DateTime.now
          puts new_data

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
