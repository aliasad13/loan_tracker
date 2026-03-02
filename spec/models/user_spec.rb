require '../rails_helper'

RSpec.describe User, type: :model do

  let(:user){FactoryBot.create(:user)}

  describe 'validate the presence of attributes' do

    it 'User to be present' do
      expect(user).to be_present
    end

    it 'expect the user to have a username' do
      expect(user.username).to be_present
    end

    it "expect the user to have an email" do
      expect(user.email).to be_present
    end

  end

  describe 'validates uniqueness of attributes' do
    before do
      FactoryBot.create(:user, email: 'user2hello@example.com', username: 'userasdas2')
    end

    it 'expects username to be unique' do
      new_user = User.new(email: 'anothersadadsa@example.com', username: 'userasdas2', password: 'password123', role: 'user')
      expect(new_user.valid?).to be false
      expect(new_user.errors[:username]).to include('has already been taken')
    end

    it 'expects email to be unique' do
      new_user = User.new(email: 'user2hello@example.com', username: 'user2asdasdahsdhj', password: 'password123', role: 'user')
      expect(new_user.valid?).to be false
      expect(new_user.errors[:email]).to include('has already been taken')
    end
  end

  describe 'respond to methods' do

    let(:user1){FactoryBot.create(:user)}

    it 'expect user to have a method can_request_loan?' do
      expect(user.respond_to?(:can_request_loan?)).to be_truthy
    end
  end

  context 'user has wallet balance > 0' do
    let(:user1){FactoryBot.create(:user)}
    let(:wallet){Wallet.create(balance: 10000, user_id: user1.id)}

    it 'expect user to be able to request loan' do
      expect(user1.can_request_loan?).to be_truthy
    end
  end

  context 'user has wallet balance < 0' do
    let(:user2){FactoryBot.create(:user)}

    it 'expect user to be unable to request loan' do
      user2.wallet.update(balance: 0)
      expect(user2.can_request_loan?).to be_falsey
    end
    
  end


end
