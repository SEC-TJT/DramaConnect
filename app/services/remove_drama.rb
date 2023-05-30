# frozen_string_literal: true

module DramaConnect
  # Add a visitor to another owner's existing dramalist
  class RemoveDrama
    # Error for owner cannot be visitor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that drama'
      end
    end

    def self.call(requestor:, drama_id:)
      drama = Drama.first(id: drama_id)
      policy = DramaPolicy.new(requestor, drama)
      raise ForbiddenError unless policy.can_delete?

      drama.delete
    end
  end
end
