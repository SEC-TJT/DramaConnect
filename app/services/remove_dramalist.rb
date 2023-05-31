# frozen_string_literal: true

module DramaConnect
  # Add a visitor to another owner's existing dramalist
  class RemoveDramalist
    # Error for owner cannot be visitor
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that dramaList'
      end
    end

    def self.call(auth:, dramalist_id:)
      dramalist = Dramalist.first(id: dramalist_id)
      policy = DramalistPolicy.new(auth[:account], dramalist, auth[:scope])
      raise ForbiddenError unless policy.can_delete?

      dramalist.delete
    end
  end
end
