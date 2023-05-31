# frozen_string_literal: true

module DramaConnect
  # Authorize an account
  class AuthorizeAccount
    # Error if requesting to see forbidden account
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that account'
      end
    end

    def self.call(auth:, username:, auth_scope:, isOwner:)
      account = Account.first(username: username)
      policy = AccountPolicy.new(auth[:account], account)
      policy.can_view? ? account : raise(ForbiddenError)

      raise ForbiddenError unless policy.can_view?

      isOwner ? account_and_token(account, auth_scope) : account(account)
    end

    def self.account(account)
      {
        type: 'visitor_account',
        attributes: {
          account: account
        }
      }
    end

    def self.account_and_token(account, auth_scope)
      {
        type: 'authorized_account',
        attributes: {
          account: account,
          auth_token: AuthToken.create(account, auth_scope)
        }
      }
    end
  end
end