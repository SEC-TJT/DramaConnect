# frozen_string_literal: true

module DramaConnect
  # Service object to create a new project for an owner
  class CreateDramalistForOwner
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to create dramalists'
      end
    end

    # def self.call(owner_id:, dramalist_data:)
    #   Account.find(id: owner_id)
    #          .add_owned_dramalist(dramalist_data)
    # end
    def self.call(auth:, dramalist_data:)
      raise ForbiddenError unless auth[:scope].can_write?('dramalists')

      auth[:account].add_owned_dramalist(dramalist_data)
    end
  end
end
