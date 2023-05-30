# frozen_string_literal: true

module DramaConnect
  # Add a visitor to another owner's existing dramalist
  class UpdateDramalist
    # Error for owner cannot be visitor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to update this dramaslist'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a dramalist with those attributes'
      end
    end

    def self.call(account:, list_id:, dramalist_data:)
      dramalist = Dramalist.find(id: list_id)
      policy = DramalistPolicy.new(account, dramalist)
      raise ForbiddenError unless policy.can_edit?

      dramalist.update(dramalist_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
