# frozen_string_literal: true

# Policy to determine if account can view a project
class DramaPolicy
  def initialize(account, drama)
    @account = account
    @drama = drama
  end

  def can_view?
    account_visits_on_dramalist? || account_owns_dramalist?
  end

  def can_edit?
    account_owns_dramalist? || account_visits_on_dramalist?
  end

  def can_delete?
    account_owns_dramalist? || account_visits_on_dramalist?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def account_owns_dramalist?
    puts @drama.dramalist.owner
    @drama.dramalist.owner == @account
  end

  def account_visits_on_dramalist?
    @drama.dramalist.visitors.include?(@account)
  end
end
