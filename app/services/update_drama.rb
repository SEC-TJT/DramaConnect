# frozen_string_literal: true

module DramaConnect
  # Add a visitor to another owner's existing dramalist
  class UpdateDrama
    # Error for owner cannot be visitor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to update this dramas'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a drama with those attributes'
      end
    end

    def self.call(account:, drama_id:, drama_data:)
      drama = Drama.find(id: drama_id)
      policy = DramaPolicy.new(account, drama)
      raise ForbiddenError unless policy.can_edit?

      drama.update(drama_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
