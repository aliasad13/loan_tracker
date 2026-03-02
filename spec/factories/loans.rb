FactoryBot.define do
  factory :loan do
    amount {5000}
    interest_rate {2.5}
    state {"requested"}
    user_id {1}

  end
end
