module LoansHelper
  def payment_amount_value(loan)
    loan.total_amount_due > loan.user.wallet.balance ? loan.user.wallet.balance : loan.total_amount_due
  end
end