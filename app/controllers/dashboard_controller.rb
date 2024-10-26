class DashboardController < ApplicationController
  def index
    if current_user.admin?
      render 'admin_dashboard'
    else
      @active_loan = current_user.loans.find_by(state: Loan::ACTIVE_STATES)
      @closed_loans = current_user.loans.where(state: ['closed', 'rejected'])
      @wallet_balance = current_user.wallet&.balance || 0 # Get the user's wallet balance
      render 'user_dashboard'
    end
  end
end
