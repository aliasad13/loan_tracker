class Ability
  include CanCan::Ability
  def initialize(user)
    user ||= User.new

    if user.admin?
      can :manage, :all
    else
      can :read, Loan, user_id: user.id    # Users can read their own loans
      can :open_loan, Loan, user_id: user.id    # Users can read their own loans
      can :create, Loan                    # Users can request a new loan
      can :update, Loan, user_id: user.id  # Users can update loans they own
      can :accept_adjustment, Loan, user_id: user.id
      can :request_readjustment, Loan, user_id: user.id
      can :repay, Loan, user_id: user.id
      can :transaction_history, Loan, user_id: user.id
      can :active_loans, Loan, user_id: user.id
      can :state_logs, Loan, user_id: user.id
      can :reject, Loan, user_id: user.id
    end
  end
end
