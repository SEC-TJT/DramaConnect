# frozen_string_literal: true

module DramaConnect
  # Add a visitor to another owner's existing account
  class UpdateAccount
    # Error for owner cannot be visitor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to update this account'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a account with those attributes'
      end
    end

    def self.call(auth:, username:, account_data:)
      account = Account.find(username: username)
      policy = AccountPolicy.new(auth[:account], account, auth[:scope])
      raise ForbiddenError unless policy.can_edit?

      account.update(account_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
