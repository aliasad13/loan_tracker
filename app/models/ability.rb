class Ability
  include CanCan::Ability
  def initialize(user)
    user ||= User.new

    if user.admin?
      can :manage, :all
    else
      can :read, Loan, user_id: user.id    # Users can read their own loans
      can :create, Loan                    # Users can request a new loan
      can :update, Loan, user_id: user.id  # Users can update loans they own
      can :accept_adjustment, Loan, user_id: user.id  # Users can update loans they own
      can :request_readjustment, Loan, user_id: user.id  # Users can update loans they own
    end
  end
end
