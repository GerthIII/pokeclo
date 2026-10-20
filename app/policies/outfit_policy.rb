class OutfitPolicy < ApplicationPolicy
  # this will show the dashboard if a user is logged in
  def dashboard?
    user.present?
  end

  def try_on?
    record.user == user
  end

  def show?
    record.user == user
  end

  def update?
    record.user == user
  end

  def create?
    user.present?
  end

  def destroy?
    record.user == user
  end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(user: user)
    end
  end
end
