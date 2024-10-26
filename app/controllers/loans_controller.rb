class LoansController < ApplicationController
  load_and_authorize_resource  #what does this do
  before_action :set_loan, only: [:show, :reject, :accept_adjustment, :accept_with_adjustment,
                                  :request_readjustment, :open_loan, :close_loan]

  def index
    if current_user.admin?
      redirect_to admin_index_loans_path
    else
      @loans = current_user.loans
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
    end
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
      redirect_to loans_path, notice: 'Loan accepted successfully.'
    else
      redirect_to loans_path, alert: 'Unable to accept loan.'
    end
  end

  def open_loan
    if @loan and @loan.open!
      redirect_to loans_path, notice: 'Loan opened successfully.'
    else
      redirect_to loans_path, alert: 'Unable to open loan.'
    end
  end

  def close_loan
    if @loan and @loan.close!
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

  private

  def loan_params
    params.require(:loan).permit(:amount, :interest_rate)
  end

  def set_loan
    @loan = Loan.find_by(id: params[:id])
  end

end