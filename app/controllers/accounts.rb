# frozen_string_literal: true

require 'roda'
require_relative './app'

module DramaConnect
  # Web controller for DramaConnect API
  class Api < Roda
    route('accounts') do |routing| # rubocop:disable Metrics/BlockLength
      @account_route = "#{@api_root}/accounts"
      routing.on String do |username|
        routing.halt(403, UNAUTH_MSG) unless @auth_account

        # GET api/v1/accounts/[username]
        routing.get do
          auth = AuthorizeAccount.call(
            auth: @auth, username: username,
            auth_scope: AuthScope.new(AuthScope::READ_ONLY),
            isOwner: username == @auth_account.username
          )
          { data: auth }.to_json
        rescue StandardError => e
          puts "GET ACCOUNT ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API Server Error' }.to_json
        end

        # PUT api/v1/accounts/[username]
        routing.post('update') do
          data_account = JSON.parse(routing.body.read)
          account = UpdateAccount.call(
            auth: @auth,
            username:,
            account_data: data_account
          )
          response.status = 200
          { message: 'Account updated', data: data_account }.to_json
        rescue UpdateAccount::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue UpdateAccount::IllegalRequestError => e
          routing.halt 400, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.warn "Could not update account: #{e.message}"
        end
      end

      # POST api/v1/accounts
      routing.post do
        account_data = SignedRequest.new(Api.config).parse(request.body.read)
        new_account = Account.create(account_data)

        response.status = 201
        response['Location'] = "#{@account_route}/#{new_account.username}"
        { message: 'Account created', data: new_account }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT:: #{account_data.keys}"
        routing.halt 400, { message: 'Illegal Request' }.to_json
      rescue SignedRequest::VerificationError
        routing.halt 403, { message: 'Must sign request' }.to_json
      rescue StandardError => e
        Api.logger.error 'Unknown error saving account'
        routing.halt 500, { message: 'Error creating account' }.to_json
      end

      #  GET api/v1/accounts
      routing.is do
        routing.halt(403, UNAUTH_MSG) unless @auth_account
        accounts = GetAccountList.call
        response.status = 200
        { message: 'Get accounts', data: accounts }.to_json
      end
    end
  end
end
