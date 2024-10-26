class Wallet < ApplicationRecord
  belongs_to :user

  validates :balance, presence: true, numericality: { greater_than_or_equal_to: 0 }


  def transfer_to!(other_wallet, amount)
    Wallet.transaction do
      self.update!(balance: balance - amount)
      other_wallet.update!(balance: other_wallet.balance + amount)
    end
  end

end
