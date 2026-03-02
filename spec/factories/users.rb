FactoryBot.define do
  factory :user do
    email { "user@gmaasdasilasd.com" }
    username { "userassd" }
    password { "password123" } # Add a valid password
    role { "user" }
    created_at { Time.now }
    updated_at { Time.now }
  end
end
