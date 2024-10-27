class LoansController < ApplicationController
  load_and_authorize_resource  #what does this do
  before_action :set_loan, only: [:show, :reject, :accept_adjustment, :accept_with_adjustment,
                                  :request_readjustment, :open_loan, :close_loan, :repay]

  def index
    if current_user.admin?
      redirect_to admin_index_loans_path
    else
      @loans = current_user.loans.page(params[:page]).per(5)
    end
  end

  def admin_index
    authorize! :manage, Loan #what does this do
    filter = params[:filter]
    if filter == 'requested'
      @loans = Loan.where(state: 'requested')
    elsif filter == 'readjustment_requested'
      @loans = Loan.where(state: 'readjustment_requested')
    elsif filter == 'open'
      @loans = Loan.where(state: 'open')
    end.paginate(page: params[:page], per_page: 5)
  end

  def show
    @adjustments = @loan.loan_adjustments.reverse
  end

  def new
    @loan = current_user.loans.build
  end

  def create
    @loan = current_user.loans.build(loan_params)
    if @loan.save
      redirect_to @loan, notice: 'Loan request submitted successfully.'
    else
      redirect_to loans_path, notice: 'Loan request exists.'
    end
  end

  # Admin actions
  def approve
    if @loan and @loan.approve!
      redirect_to admin_index_loans_path, notice: 'Loan approved successfully.'
    else
      redirect_to admin_index_loans_path, alert: 'Unable to approve loan.'
    end
  end

  def reject
    if @loan and @loan.reject!
      redirect_to admin_index_loans_path, notice: 'Loan rejected successfully.'
    else
      redirect_to admin_index_loans_path, alert: 'Unable to reject loan.'
    end
  end

  def accept_adjustment
    if @loan and @loan.accept_adjustment!
      CalculateInterestJob.perform_later(@loan.id)
      redirect_to loans_path, notice: 'Loan accepted successfully.'
    else
      redirect_to loans_path, alert: 'Unable to accept loan.'
    end
  end

  def open_loan
    if @loan and @loan.open_loan!
      new_wallet_balance = @loan.user.wallet.balance + @loan.amount
      @loan.user.wallet.update(balance: new_wallet_balance)
      CalculateInterestJob.perform_later(@loan.id)
      redirect_to loans_path, notice: 'Loan opened successfully. Amount Credited to account'
    else
      redirect_to loans_path, alert: 'Unable to open loan.'
    end
  end

  def close_loan
    if @loan and @loan.close_loan!
      redirect_to loans_path, notice: 'Loan closed successfully.'
    else
      redirect_to loans_path, alert: 'Unable to close loan.'
    end
  end
  def accept_with_adjustment
    if @loan and @loan.accept_with_adjustment!
      @loan.loan_adjustments.build(
        previous_amount: @loan.amount,
        new_amount: params[:loan][:amount],
        previous_interest_rate: @loan.interest_rate,
        new_interest_rate: params[:loan][:interest_rate]
      )
      @loan.amount = loan_params[:amount]
      @loan.interest_rate = loan_params[:interest_rate]
      if @loan.save!
        redirect_to admin_index_loans_path, notice: 'Loan accepted successfully.'
      else
        redirect_to admin_index_loans_path, alert: 'error while saving record.'
      end
    else
      redirect_to admin_index_loans_path, alert: 'Unable to accept loan.'
    end
  end

  def request_readjustment
    if @loan and @loan.request_readjustment!
      redirect_to loans_path, notice: 'Loan asked for readjustment.'
    else
      redirect_to loans_path, notice: 'something went wrong'
    end
  end

  def repay
    payment_amount = loan_params[:payment_amount].to_f
    if @loan
      loan_user = @loan.user
      admin_user = User.where(role: 'admin').first
      user_wallet_balance = loan_user.wallet.balance
      user_wallet_balance_after_pay = user_wallet_balance - payment_amount
      if user_wallet_balance_after_pay <= 0.0
        loan_user.wallet.update(balance: 0.0)
        admin_new_balance = admin_user.wallet.balance + user_wallet_balance
        admin.wallet.update(balance: admin_new_balance)
        @loan.update(total_amount_due: 0.00)
        @loan.loan_transactions.create(transaction_amount: user_wallet_balance)
        @loan.close!
        redirect_to loan_path(@loan), notice: 'We have closed the loan, congratulations'
      else
        @loan.user.wallet.update(balance: user_wallet_balance_after_pay)
        admin_new_balance = admin_user.wallet.balance + payment_amount
        admin_user.wallet.update(balance: admin_new_balance)
        balance_loan_due_amount = @loan.total_amount_due - payment_amount
        @loan.update(total_amount_due: balance_loan_due_amount)
        @loan.loan_transactions.create(transaction_amount: payment_amount)
        if @loan.total_amount_due.zero?
          @loan.close!
          redirect_to loan_path(@loan), notice: "Congratulations, full amount paid and Loan closed"
        else
          redirect_to loan_path(@loan), notice: "#{payment_amount} deducted from your wallet. Loan Balance: #{balance_loan_due_amount}"
        end
      end
    else
      redirect_to loans_path, alert: 'Unable to repay.'
    end
  end

  def transaction_history
    if @loan
      @loan_transactions = @loan.loan_transactions
    end
  end

  private

  def loan_params
    params.require(:loan).permit(:amount, :interest_rate, :total_amount_due, :payment_amount)
  end

  def set_loan
    @loan = Loan.find_by(id: params[:id])
  end

end