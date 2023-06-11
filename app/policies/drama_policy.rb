# frozen_string_literal: true

# Policy to determine if account can view a dramalist
class DramaPolicy
  def initialize(account, drama, auth_scope = nil)
    @account = account
    @drama = drama
    @auth_scope = auth_scope
  end

  def can_view?
    can_read? && (account_owns_dramalist? || account_visits_on_dramalist?)
  end

  def can_edit?
    can_write? && account_owns_dramalist?
  end

  def can_delete?
    can_write? && account_owns_dramalist?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def can_read?
    @auth_scope ? @auth_scope.can_read?('dramas') : false
  end

  def can_write?
    @auth_scope ? @auth_scope.can_write?('dramas') : false
  end

  def account_owns_dramalist?
    puts @drama.dramalist.owner
    @drama.dramalist.owner == @account
  end

  def account_visits_on_dramalist?
    @drama.dramalist.visitors.include?(@account)
  end
end
