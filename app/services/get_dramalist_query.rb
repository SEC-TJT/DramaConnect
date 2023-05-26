# frozen_string_literal: true

module DramaConnect
  # Add a visitor to another owner's existing dramalist
  class GetDramalistQuery
    # Error for owner cannot be visitor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that dramalist'
      end
    end

    # Error for cannot find a dramalist
    class NotFoundError < StandardError
      def message
        'We could not find that dramalist'
      end
    end

    def self.call(account:, dramalist:)
      raise NotFoundError unless dramalist

      policy = DramalistPolicy.new(account, dramalist)
      raise ForbiddenError unless policy.can_view?

      dramalist.full_details.merge(policies: policy.summary)
    end
  end
end
