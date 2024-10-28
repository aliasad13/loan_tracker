class CalculateInterestJob < ApplicationJob
  queue_as :default


  def perform(*args)
    Loan.where(state: 'open').find_each do |loan|
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
      loan.update!(total_amount_due: new_total, last_interest_calculation_at: Time.now)
      Rails.logger.info "Interest calculated for Loan ##{loan.id}: Added #{interest.round(2)}, New total: #{new_total.round(2)}"
    end
  rescue => e
    Rails.logger.error "Error calculating monthly interest for Loan ##{loan.id}: #{e.message}"
  end
end
