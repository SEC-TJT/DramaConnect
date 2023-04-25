# frozen_string_literal: true

module DramaConnect
  # Create new configuration for a project
  class CreateDramaForDramalist
    def self.call(dramalist_id:, drama_data:)
      Dramalist.first(id: dramalist_id)
             .add_drama(drama_data)
    end
  end
end
