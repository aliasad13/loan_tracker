class Loan < ApplicationRecord
  belongs_to :user
  has_many :loan_adjustments, dependent: :destroy

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :interest_rate, presence: true, numericality: { greater_than: 0 }
  # validate :no_active_loan, on: :create

  include AASM

  ACTIVE_STATES = %w[requested approved waiting_for_adjustment_acceptance readjustment_requested open].freeze

  aasm column: 'state' do
    state :requested, initial: true
    state :approved
    state :waiting_for_adjustment_acceptance
    state :readjustment_requested
    state :rejected
    state :open
    state :closed

    event :approve do
      transitions from: :requested, to: :approved
    end

    event :reject do
      transitions from: [:requested, :readjustment_requested, :waiting_for_adjustment_acceptance], to: :rejected
    end

    event :accept_with_adjustment do # from admin to user, accepted with a readjustment, when the user sends a request. Now the admin will wait for user's response
      transitions from: [:requested, :readjustment_requested],
                  to: :waiting_for_adjustment_acceptance
    end

    event :request_readjustment do # from user to admin, the user can now accept/reject/request another readjustment
      transitions from: :waiting_for_adjustment_acceptance,
                  to: :readjustment_requested
    end

    event :accept_adjustment do
      transitions from: :waiting_for_adjustment_acceptance, to: :open
    end

    event :open_loan do
      transitions from: :approved, to: :open
    end

    event :close do
      transitions from: :open, to: :closed
    end
  end

  # loan = Loan.create(amount: 1000, interest_rate: 10) => initial state: requested

  # Now we can use AASM methods like:
  # loan.requested?      # => true
  # loan.may_approve?    # => true
  # loan.approve!        # Changes state to 'approved'
  # loan.approved?       # => true
  #
  # # If you try invalid transition:
  # loan.close!         # Will raise AASM::InvalidTransition

  # Loan.aasm.states.map(&:name)  # Lists all possible states
  # Loan.requested                 # Lists all loans in requested state
  # Loan.approved                 # Lists all approved loans

  def total_interest_accrued
    return 0 unless open?
    (total_amount_due || amount) - amount
  end

  def formatted_total_interest
    total_interest_accrued.round(2)
  end

  def formatted_total_amount
    (total_amount_due || amount).round(2)
  end

  private

  def no_active_loan
    if user.loans.where(state: ACTIVE_STATES).exists?
      errors.add(:base, 'You already have an active loan') #errors will be added onto loan.errors when a new loan is created
    end
  end

end
