# frozen_string_literal: true

module DramaConnect
  # Add a visitor to another owner's existing dramalist
  class CreateDrama
    # Error for owner cannot be visitor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more dramas'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a drama with those attributes'
      end
    end

    def self.call(account:, dramalist:, drama_data:)
      policy = DramalistPolicy.new(account, dramalist)
      raise ForbiddenError unless policy.can_add_dramas?

      add_drama(dramalist, drama_data)
    end

    def self.add_drama(dramalist, drama_data)
      dramalist.add_drama(drama_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
