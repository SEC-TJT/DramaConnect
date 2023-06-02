# frozen_string_literal: true

module DramaConnect
  # Add a visitor to another owner's existing dramalist
  class RemoveVisitor
    # Error for owner cannot be visitor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(auth:, visitor_email:, dramalist_id:)
      puts("🥲")
      dramalist = Dramalist.first(id: dramalist_id)
      visitor = Account.first(email: visitor_email)
      policy = VisitingRequestPolicy.new(dramalist, auth[:account], visitor, auth[:scope])
      puts(policy.can_remove?)
      raise ForbiddenError unless policy.can_remove?

      dramalist.remove_visitor(visitor)
      puts(dramalist.visitors)
      visitor
    end
  end
end
