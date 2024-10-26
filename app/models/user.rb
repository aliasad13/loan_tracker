class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


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

end
