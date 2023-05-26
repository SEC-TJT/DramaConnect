# frozen_string_literal: true

module DramaConnect
  # Add a visitor to another owner's existing dramalist
  class GetAccountQuery
    # Error if requesting to see forbidden account
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that dramalist'
      end
    end

    def self.call(requestor:, username:)
      account = Account.first(username:)

      policy = AccountPolicy.new(requestor, account)
      policy.can_view? ? account : raise(ForbiddenError)
    end
  end
end
