# frozen_string_literal: true

module DramaConnect
  # Policy to determine if an account can view a particular dramalist
  class DramalistPolicy
    def initialize(account, dramalist, auth_scope = nil)
      @account = account
      @dramalist = dramalist
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && (account_is_owner? || account_is_visitor?)
    end

    # duplication is ok!
    def can_edit?
      can_write? && account_is_owner?
    end

    def can_delete?
      can_write? && account_is_owner?
    end

    def can_add_dramas?
      can_write? && account_is_owner?
    end

    def can_remove_dramas?
      can_write? && account_is_owner?
    end

    def can_add_visitors?
      can_write? && account_is_owner?
    end

    def can_remove_visitors?
      can_write? && (account_is_owner? || account_is_visitor?)
    end

    def can_visit?
      !(account_is_owner? or account_is_visitor?)
    end

    def summary
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_add_dramas: can_add_dramas?,
        can_delete_dramas: can_remove_dramas?,
        can_add_visitors: can_add_visitors?,
        can_remove_visitors: can_remove_visitors?,
        can_visit: can_visit?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('dramalists') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('dramalists') : false
    end

    def account_is_owner?
      @dramalist.owner == @account
    end

    def account_is_visitor?
      @dramalist.visitors.include?(@account)
    end
  end
end
