# frozen_string_literal: true

module DramaConnect
  # Add a visitor to another owner's existing dramalist
  class AddVisitor
    # Error for owner cannot be visitor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as visitor'
      end
    end

    def self.call(account:, dramalist:, visitor_email:)
      invitee = Account.first(email: visitor_email)
      policy = VisitingRequestPolicy.new(dramalist, account, invitee)
      raise ForbiddenError unless policy.can_invite?

      dramalist.add_visitor(invitee)
      invitee
    end
  end
end
