# frozen_string_literal: true

module DramaConnect
  # Policy to determine if an account can view a particular project
  class VisitingRequestPolicy
    def initialize(dramalist, requestor_account, target_account)
      @dramalist = dramalist
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = DramalistPolicy.new(requestor_account, dramalist)
      @target = DramalistPolicy.new(target_account, dramalist)
    end

    def can_invite?
      @requestor.can_add_visitors? && @target.can_visit?
    end

    def can_remove?
      @requestor.can_remove_visitors? && target_is_visitor?
    end

    private

    def target_is_visitor?
      @dramalist.visitors.include?(@target_account)
    end
  end
end
