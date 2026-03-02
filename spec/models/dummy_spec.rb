require '../rails_helper'

RSpec.describe Dummy, type: :model do
  describe 'age context' do
    let(:dummy) { FactoryBot.create(:dummy) }

    it 'expects the age to be present' do
      expect(dummy.age).not_to be_nil
    end

    it 'expects age to be 1' do
      expect(dummy.age).to eq(1)
    end

  end

  context 'with different age' do
    let(:dummy2) { Dummy.new(name: 'abc', age: '23', born_at: '2010/10/11') }

    it 'expects age to be greater than 1' do
      expect(dummy2.age).to be > 1
    end

  end


end