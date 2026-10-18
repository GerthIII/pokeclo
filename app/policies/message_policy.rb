class MessagePolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

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
