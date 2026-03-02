FactoryBot.define do
  factory :dummy do
    name { "MyString" }
    age { 1 }
    born_at { "2025-01-10 17:16:34" }
    sequence(:email) { |n| "test_#{SecureRandom.hex(5)}_#{n}@example.com" }
  end
end