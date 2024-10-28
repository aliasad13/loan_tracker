class CalculateInterestJob < ApplicationJob
  queue_as :default


  def perform(*args)
    Loan.where(state: 'open').find_each do |loan| # now = 10:04,  last calculated = 10:00 <= 9:59
      if loan.last_interest_calculation_at.nil? || loan.last_interest_calculation_at <= 5.minutes.ago
        Rails.logger.info "Started calculation for Loan ##{loan.id}"
        calculate_monthly_interest(loan)
      end
    end
  end

  private

  def calculate_monthly_interest(loan)
    ApplicationRecord.transaction do
      annual_rate = BigDecimal(loan.interest_rate.to_s) / 100
      monthly_rate = annual_rate / BigDecimal('12')
      interest = BigDecimal(loan.amount.to_s) * monthly_rate #calculate on principle amount
      new_total = BigDecimal((loan.total_amount_due || loan.amount).to_s) + interest
      loan_user = loan.user
      user_wallet_balance = loan_user.wallet.balance
      if new_total > user_wallet_balance
        admin_user = User.find_by(role: 'admin')
        admin_new_balance = admin_user.wallet.balance + user_wallet_balance
        loan_user.wallet.update!(balance: 0.0)
        admin_user.wallet.update!(balance: admin_new_balance)
        loan.update!(total_amount_due: 0.00)
        loan.loan_transactions.create!(transaction_amount: user_wallet_balance)
        loan.close!
        Rails.logger.info "__________________ \n\n\n Loan #{loan.id} as total interest + amount > wallet balance \n\n\n---------------------------------------------------"
      end
      loan.update!(total_amount_due: new_total, last_interest_calculation_at: Time.now)
      Rails.logger.info "Interest calculated for Loan ##{loan.id}: Added #{interest.round(2)}, New total: #{new_total.round(2)}"
    end
  rescue => e
    Rails.logger.error "Error calculating monthly interest for Loan ##{loan.id}: #{e.message}"
  end
end
