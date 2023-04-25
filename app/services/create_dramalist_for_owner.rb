# frozen_string_literal: true

module DramaConnect
  # Service object to create a new project for an owner
  class CreateDramalistForOwner
    def self.call(owner_id:, dramalist_data:)
      Account.find(id: owner_id)
             .add_owned_dramalist(dramalist_data)
    end
  end
end
