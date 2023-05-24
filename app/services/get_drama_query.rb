# frozen_string_literal: true

module DramaConnect
  # Add a visitor to another owner's existing dramalist
  class GetDramaQuery
    # Error for owner cannot be visitor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that drama'
      end
    end

    # Error for cannot find a dramalist
    class NotFoundError < StandardError
      def message
        'We could not find that drama'
      end
    end

    # Drama for given requestor account
    def self.call(requestor:, drama:)
      raise NotFoundError unless drama

      policy = DramaPolicy.new(requestor, drama)
      raise ForbiddenError unless policy.can_view?

      drama
    end
  end
end
