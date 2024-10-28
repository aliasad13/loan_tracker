class DashboardController < ApplicationController
  def index
    if current_user.admin?
      @wallet_balance = current_user.wallet&.balance || 0
      render 'admin_dashboard'
    else
      @active_loans = current_user.loans.where(state: Loan::ACTIVE_STATES)
      params[:page] ||= 1
      @closed_loans = current_user.loans.where(state: ['closed', 'rejected']).order('created_at DESC').page(params[:page]).per(10)
      @wallet_balance = current_user.wallet&.balance || 0
      render 'user_dashboard'
    end
  end
end
