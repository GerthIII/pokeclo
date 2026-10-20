class MessagePolicy < ApplicationPolicy
  # DECISION: Messages have no user_id; ownership is checked through their outfit.
  #   Rejected: adding user_id (migration + duplicate data the outfit already has).
  def confirm?
    record.outfit.user == user
  end

  def create?
    record.outfit.user == user
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:outfit).where(outfits: { user_id: user.id })
    end
  end
end
