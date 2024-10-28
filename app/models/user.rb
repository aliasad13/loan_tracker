class User < ApplicationRecord

  after_create :create_wallet

  has_one :wallet, dependent: :destroy
  has_many :loans, dependent: :destroy
  validates :username, presence: true, uniqueness: {case_sensitive: true}

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  attr_accessor :login



  enum role: { admin: 'admin', user: 'user' }
  #enum role has many purposes:
  # 1.tells Rails that the role attribute can have either admin or user as its value.
  # 2.User.admin will return all users with the role of admin. User.user will return all users with the role of user.
  # 3. user.admin? or user.user?
  # 4.You can set the role like this: user.role = :admin or user.role = :user.


  after_initialize do # ensures that whenever you create a new User object (even if it’s not yet saved), the role will default to :user.
    self.role ||= :user if new_record?
    #if we are not creating a user with a role, then give his role as user
  end

  #why new_record?
  # after initialize will run after instantiating new and existing record. to limit this to only new record
  # instantiating existing: user = User.find(1), instantiating new record: user = User.new


  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions).where(["lower(username) = :value OR lower(email) = :value", { value: login.downcase }]).first
    else
      where(conditions).first
    end
  end
  
  def active_loan
    loans.find_by(state: Loan::ACTIVE_STATES)
  end

  def can_request_loan?
    # !active_loan.present?
    wallet.balance > 0
  end

  private

  def create_wallet
    initial_balance = admin? ? 1000000 : 10000
    create_wallet!(balance: initial_balance) #The create_wallet! method is automatically provided by Rails through the has_one association in your User model.
  end

end
