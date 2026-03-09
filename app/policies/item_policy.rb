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

  def capture_photo?
    user.present?
  end

  def show?
    true
  end

  def create?
    true
  end

  def update?
  record.user == user
  # record: the restaurant passed to the `authorize` method in controller
  # user: the `current_user` signed in with Devise
  end

  class Scope < ApplicationPolicy::Scope
    # Only the user can see hist Index, show, create and edit
    def resolve
      scope.where(user: user)
    end

  end
end
