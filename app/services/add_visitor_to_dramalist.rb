# frozen_string_literal: true

module DramaConnect
  # Add a collaborator to another owner's existing project
  class AddVisitorToDramalist
    # Error for owner cannot be collaborator
    class OwnerNotVisitorError < StandardError
      def message = 'Owner cannot be visitor of dramalist'
    end

    def self.call(email:, dramalist_id:)
      visitor = Account.first(email:)
      dramalist = Dramalist.first(id: dramalist_id)
      raise(OwnerNotVisitorError) if dramalist.owner.id == visitor.id

      dramalist.add_visitor(visitor)
    end
  end
end
