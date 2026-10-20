class ItemPolicy < ApplicationPolicy
  # this will show the dashboard if a user is logged in
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
    # Only the user can see this Index, show, create and edit
    def resolve
      scope.where(user: user)
    end
  end
end
