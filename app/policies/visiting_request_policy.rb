# frozen_string_literal: true

module DramaConnect
  # Policy to determine if an account can view a particular dramalist
  class VisitingRequestPolicy
    def initialize(dramalist, requestor_account, target_account, auth_scope = nil)
      @dramalist = dramalist
      @requestor_account = requestor_account
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = DramalistPolicy.new(requestor_account, dramalist, auth_scope)
      @target = DramalistPolicy.new(target_account, dramalist, auth_scope)
    end

    def can_invite?
      can_write? &&
        (@requestor.can_add_visitors? && @target.can_visit?)
    end

    def can_remove?
      can_write? &&
        (@requestor.can_remove_visitors? && target_is_visitor?)
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('dramalists') : false
    end

    def target_is_visitor?
      @dramalist.visitors.include?(@target_account)
    end
  end
end
