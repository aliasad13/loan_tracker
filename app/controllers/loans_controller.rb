class LoansController < ApplicationController
  load_and_authorize_resource  #
  before_action :set_loan, only: [:show, :reject, :accept_adjustment, :accept_with_adjustment,
                                  :request_readjustment, :open_loan, :close_loan, :repay]

  def index
    if current_user.admin?
      redirect_to admin_index_loans_path
    else
      @loans = current_user.loans.order('created_at DESC').page(params[:page]).per(5)
    end
  end

  def admin_index
    authorize! :manage, Loan #
    @loans = Loan.all
    filter = params[:filter]
    @loans = case filter
             when 'requested'
               @loans.where(state: 'requested').order('created_at DESC')
             when 'readjustment_requested'
               @loans.where(state: 'readjustment_requested').order('created_at DESC')
             when 'open'
               @loans.where(state: 'open').order('created_at DESC')
             else
               @loans.order('created_at DESC')
             end

    @loans = @loans.page(params[:page]).per(5)
  end

  def active_loans
    @active_loans = current_user.loans.where(state: Loan::ACTIVE_STATES).page(params[:page]).per(10)
  end

  def show
    @adjustments = @loan.loan_adjustments.reverse
  end

  def new
    if current_user.can_request_loan?
      @loan = current_user.loans.build
    else
      redirect_to root_path, alert: 'Sorry You cannot apply for any loans at the moment. Your wallet balance is zero'
    end
  end

  def create
    @loan = current_user.loans.build(loan_params)
    if @loan.save
      redirect_to @loan, notice: 'Loan request submitted successfully.'
    else
      redirect_to loans_path, alert: @loan.errors.full_messages.to_sentence
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
      changes_on_opening_loan
      redirect_to loans_path, notice: 'Loan accepted successfully.'
    else
      redirect_to loans_path, alert: 'Unable to accept loan.'
    end
  end

  def open_loan
    if @loan and @loan.open_loan!
      changes_on_opening_loan
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
    if @loan
      if @loan.amount.to_f == params[:loan][:amount].to_f and @loan.interest_rate.to_f == params[:loan][:interest_rate].to_f
        redirect_to admin_index_loans_path, alert: 'Make sure to change parameters before submitting'
      else
        ApplicationRecord.transaction do
          @loan.accept_with_adjustment!
          @loan.loan_adjustments.build(
            previous_amount: @loan.amount,
            new_amount: params[:loan][:amount],
            previous_interest_rate: @loan.interest_rate,
            new_interest_rate: params[:loan][:interest_rate]
          )
          @loan.amount = loan_params[:amount]
          @loan.total_amount_due = loan_params[:amount]
          @loan.interest_rate = loan_params[:interest_rate]
          if @loan.save
            redirect_to admin_index_loans_path, notice: 'Loan accepted successfully.'
          else
            redirect_to admin_index_loans_path, alert: @loan.errors.full_messages.to_sentence
          end
        end
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
      admin_user = User.find_by(role: 'admin')

      ApplicationRecord.transaction do
        user_wallet_balance = loan_user.wallet.balance
        user_wallet_balance_after_pay = user_wallet_balance - payment_amount

        if user_wallet_balance_after_pay <= 0.0
          loan_user.wallet.update!(balance: 0.0)
          admin_new_balance = admin_user.wallet.balance + user_wallet_balance
          admin_user.wallet.update!(balance: admin_new_balance)
          @loan.update!(total_amount_due: 0.00)
          @loan.loan_transactions.create!(transaction_amount: user_wallet_balance)
          @loan.close!
          redirect_to loan_path(@loan), notice: 'We are sorry to inform you we have cleared your wallet and closed the loan'
        else
          loan_user.wallet.update!(balance: user_wallet_balance_after_pay)
          admin_new_balance = admin_user.wallet.balance + payment_amount
          admin_user.wallet.update!(balance: admin_new_balance)
          balance_loan_due_amount = @loan.total_amount_due - payment_amount
          @loan.update!(total_amount_due: balance_loan_due_amount)
          @loan.loan_transactions.create!(transaction_amount: payment_amount)

          if @loan.total_amount_due.zero?
            @loan.close!
            redirect_to loan_path(@loan), notice: "Congratulations, full amount paid and loan closed"
          else
            redirect_to loan_path(@loan), notice: "#{payment_amount} deducted from your wallet. Loan Balance: #{balance_loan_due_amount}"
          end
        end
      end
    else
      redirect_to loans_path, alert: 'Unable to repay.'
    end
  end

  def transaction_history
    if @loan
      @loan_transactions = @loan.loan_transactions
      @total_amount_paid = @loan.total_amount_paid
    end
  end

  private

  def loan_params
    params.require(:loan).permit(:amount, :interest_rate, :total_amount_due, :payment_amount)
  end

  def set_loan
    @loan = Loan.find_by(id: params[:id])
  end

  def changes_on_opening_loan
    new_wallet_balance = @loan.user.wallet.balance + @loan.amount
    @loan.user.wallet.update(balance: new_wallet_balance)
    admin_user = User.where(role: 'admin').first
    new_admin_balance = admin_user.wallet.balance - @loan.amount
    admin_user.wallet.update(balance: new_admin_balance)
    @loan.update(last_interest_calculation_at: DateTime.now)
    CalculateInterestJob.perform_later(@loan.id)
  end

end