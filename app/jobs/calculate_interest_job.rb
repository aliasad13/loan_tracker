class CalculateInterestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Loan.where(state: 'open').find_each do |loan|
      calculate_five_minute_interest(loan)
    end
  end

  private

  def calculate_five_minute_interest(loan)
    ApplicationRecord.transaction do
    # Assuming interest_rate is an annual rate
    annual_rate = loan.interest_rate / 100
    five_minute_rate = annual_rate / (365 * 24 * 12) #convert annual rate to five minute rate
    # Divides by total 5-minute periods in a year
    # 365 days: A year has 365 days
    # 24 hours per day: Each day has 24 hours.
    # 12 intervals per hour: There are 12 five-minute intervals in one hour

    interest = loan.amount * five_minute_rate
    new_total = (loan.total_amount_due || loan.amount) + interest
    loan.update!(total_amount_due: new_total)
    Rails.logger.info "Interest calculated for Loan ##{loan.id}: Added #{interest.round(2)}, New total: #{new_total.round(2)}"
    end
  rescue => e
    Rails.logger.error "Error calculating interest for Loan ##{loan.id}: #{e.message}"
  end
end
