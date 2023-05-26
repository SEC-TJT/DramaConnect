# frozen_string_literal: true

module DramaConnect
  # Policy to determine if an account can view a particular project
  class DramalistPolicy
    def initialize(account, dramalist)
      @account = account
      @dramalist = dramalist
    end

    def can_view?
      account_is_owner? || account_is_visitor?
    end

    # duplication is ok!
    def can_edit?
      account_is_owner? || account_is_visitor?
    end

    def can_delete?
      account_is_owner?
    end

    def can_leave?
      account_is_visitor?
    end

    def can_add_dramas?
      account_is_owner? || account_is_visitor?
    end

    def can_remove_dramas?
      account_is_owner? || account_is_visitor?
    end

    def can_add_visitors?
      account_is_owner?
    end

    def can_remove_visitors?
      account_is_owner?
    end

    def can_visit?
      !(account_is_owner? or account_is_visitor?)
    end

    def summary # rubocop:disable Metrics/MethodLength
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_dramas: can_add_dramas?,
        can_delete_dramas: can_remove_dramas?,
        can_add_visitors: can_add_visitors?,
        can_remove_visitors: can_remove_visitors?,
        can_visit: can_visit?
      }
    end

    private

    def account_is_owner?
      @dramalist.owner == @account
    end

    def account_is_visitor?
      @dramalist.visitors.include?(@account)
    end
  end
end
