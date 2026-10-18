class ItemPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  # this will show the dahsboard if a user is logged in
  def dashboard?
    user.present?
  end

  def analyze_photo?
    user.present?
  end

  # DECISION: Ownership is checked here AND by the scoped lookup in the controller.
  #   Two locks, so forgetting one does not leak another user's closet.
  def show?
    record.user == user
  end

  def create?
    user.present?
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user
  end

  class Scope < ApplicationPolicy::Scope
    # Only the user can see hist Index, show, create and edit
    def resolve
      scope.where(user: user)
    end

  end
end
